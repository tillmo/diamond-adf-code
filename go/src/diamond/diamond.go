////////////////////////////////////////////////////////////////////////////////
// 
// Copyright 2016 Hannes Strass, strass@informatik.uni-leipzig.de
//
// This file is part of diamond.
//
// diamond is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// diamond is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with diamond.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
// diamond.go
//
// goDIAMOND -- a reimplementation of diamond in go.
// Written with go1.6 on linux/amd64.
//
// Main improvements:
// * No more two-step solver calls, maximisation is handled via disjunctive encodings.
//   All semantics and resoning problems uniformly call clingo once.
// * Improved translation from formula to functional representation.
// * Formula representation of instances is now default.
// * A novel encoding of the three-valued one-step consequence operator for functional-representation ADFs.
// * Extensibility for new semantics via internal data structures.
//

package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"strings"
)

// An input format is something that diamond can read input in.
type InputFormat struct {
	// name for internal use
	Name string
	// string to use as command line argument
	CommandLineArgument string
	// description to explain command line argument
	CommandLineDescription string
	// file name of the associated transformation encoding
	// a transformation encoding in this case transforms the input into the default input format
	TransformationEncodingFileName string
	// some input formats have associated operators; this field contains the file name of the operator's encoding
	OperatorEncodingFileName string
	// true iff the input of the present instance uses this format
	// only exactly one input format can be used
	Active bool
}

// A semantics is something that diamond can compute interpretations for.
type Semantics struct {
	// name for internal use
	Name string
	// string to use as a command line argument
	CommandLineArgument string
	// description to explain command line argument
	CommandLineDescription string
	// file name of the semantics' associated encoding
	EncodingFileName string
	// true iff the present instance is supposed to compute interpretations for this semantics
	// multiple semantics can be computed for the same input (serially)
	Compute bool
}

// A reasoning mode is a way of producing results.
type ReasoningMode struct {
	// name for internal use
	Name string
	// string to use as a command line argument
	CommandLineArgument string
	// description to explain command line argument
	CommandLineDescription string
	// arguments that are passed to the solver whenever this mode is active
	SolverCallArguments []string
	// some reasoning modes require the creation of temporary files
	// this points to such a file in order to pass its name to the solver
	QueryTempFile *os.File
	// an encoding that hides most of the solver's output and shows only output-relevant atoms
	OutputEncodingFileName string
	// true iff the present instance is supposed to operate in this reasoning mode
	// only exactly one reasoning mode can be active at a time
	Active bool
}

// set the reasoning mode's temporary file
func (m *ReasoningMode) SetQueryTempFile(s string) {

	var tmpfileName string
	var tmpfileContent string
	
	// create the relevant constraint
	if (m.Name == "one" || m.Name == "all") { return }

	if (m.Name == "cred") {

		// to check whether a statement is credulously accepted, remove all those interpretations where the statement is not true
		// if something remains, the statement is accepted
		tmpfileContent = fmt.Sprintf(":- not t(%s).", s)
		tmpfileName = fmt.Sprintf("cred-%s.lp", s)
	}

	if (m.Name == "scep") {

		// to check whether a statement is sceptically accepted, remove all those interpretations where the statement is true
		// if something remains, the statement is not accepted
		tmpfileContent = fmt.Sprintf(":- t(%s).", s)
		tmpfileName = fmt.Sprintf("scep-%s.lp", s)
	}

	// create a temporary file with the appropriate content
	var e1 error
	m.QueryTempFile, e1 = ioutil.TempFile("", tmpfileName)

	if e1 != nil { log.Fatal(e1) }

	_, e2 := m.QueryTempFile.Write([]byte(tmpfileContent))
	if e2 != nil { log.Fatal(e2) }

	e3 := m.QueryTempFile.Close()
	if e3 != nil { log.Fatal(e3) }	
}

// return the reasoning mode's temporary file name if one exists
func (m *ReasoningMode) QueryTempFileNames() []string {

	if ( m.Name == "cred" || m.Name == "scep" ) {

		return []string{ m.QueryTempFile.Name() }
	} else {

		return []string{}
	}
}

// delete temporary files
func (m *ReasoningMode) CleanUp() {

	// remove temporary files used for querying
	if ( m.Name == "cred" || m.Name == "scep" ) {
		os.Remove(m.QueryTempFile.Name())
	}
}

// list all necessary diamond encodings here
type Encodings struct {
	cfi string
	nai string
	adm string
	com string
	prf string
	mod string
	grd string
	fnop string
	afop string
	biop string
	trans string
	show string
}

// for each string prefix, Prepend returns a function that prepends an input with prefix
func Prepend(prefix *string) func(string) string {

	return func(s string) string {

		return fmt.Sprintf("%s%s", *prefix, s)
	}
}

func main() {

	// set encoding files to the default encodings used by diamond
	enc := Encodings{
		trans: "pf2fn.lp",
		cfi: "cfi.lp",
		nai: "naiD.lp",
		adm: "adm.lp",
		com: "com.lp",
		prf: "prfD.lp",
		mod: "mod.lp",
		grd: "grd.lp",
		fnop: "fnop.lp",
		afop: "afop.lp",
		biop: "biop.lp",
		show: "show.lp" }
	
	// deal with command line arguments

	// semantics
	cfi := Semantics{ "conflict-free", "cfi", "Use three-valued conflict-free semantics", enc.cfi, false }
	nai := Semantics{ "naive", "nai", "Use naive semantics", enc.nai, false }
	adm := Semantics{ "admissible", "adm", "Use admissible semantics", enc.adm, false }
	com := Semantics{ "complete", "com", "Use complete semantics", enc.com, false }
	prf := Semantics{ "preferred", "prf", "Use preferred semantics", enc.prf, false }
	mod := Semantics{ "model", "mod", "Use model semantics", enc.mod, false }
	grd := Semantics{ "grounded", "grd", "Use grounded semantics", enc.grd, false }
	
	semantics := [7]*Semantics{ &cfi, &nai, &adm, &com, &prf, &mod, &grd }

	// for each semantics, create a command line switch
	for i := range semantics {

		flag.BoolVar(&semantics[i].Compute, semantics[i].CommandLineArgument, semantics[i].Compute, semantics[i].CommandLineDescription)
	}

	// input formats
	fn := InputFormat{ "functional", "fn", "Input uses functional representation using predicates s/1, ci/1, co/1, ci/3, co/3", "", enc.fnop, false }
	pf := InputFormat{ "formula", "pf", "Input uses propositional formula representation using predicates s/1, ac/2", enc.trans, enc.fnop, true }
	bi := InputFormat{ "bipolar", "bi", "Input uses bipolar ADF representation using predicates s/1, ac/2, sup/2, att/2", "", enc.biop, false}
	af := InputFormat{ "aspartix", "af", "Input uses Dung AF representation in ASPARTIX syntax using predicates arg/1, att/2", "", enc.afop, false}
	
	formats := [4]*InputFormat{ &fn, &pf, &bi, &af }

	// for each input format, create a command line switch
	for i := range formats {

		flag.BoolVar(&formats[i].Active, formats[i].CommandLineArgument, formats[i].Active, formats[i].CommandLineDescription)
	}

	// reasoning modes
	one := ReasoningMode{ "one", "one", "Compute one interpretation if one exists", []string{ "hallo", "-V0" }, nil, enc.show, false }
	all  := ReasoningMode{ "all", "all", "Compute all interpretations", []string{ "hallo", "-V0", "-n 0" }, nil, enc.show, true }
	cred := ReasoningMode{ "cred", "cred", "Credulous reasoning (the statement is credulously accepted iff the answer is SATISFIABLE)", []string{ "hallo", "-V0", "-q" }, nil, enc.show, false }  // TODO: for some reason the Run() command "eats" the first element of the Args list
	scep := ReasoningMode{ "scep", "scep", "Sceptical reasoning (the statment is sceptically accepted iff the answer is UNSATISFIABLE)", []string{ "hallo", "-V0", "-q" }, nil, enc.show, false } // TODO: for some reason the Run() command "eats" the first element of the Args list

	modes := [4]*ReasoningMode{ &one, &all, &cred, &scep }

	// for each reasoning mode, create a command line switch
	for i := range modes {

		flag.BoolVar(&modes[i].Active, modes[i].CommandLineArgument, modes[i].Active, modes[i].CommandLineDescription)
	}

	// additional argument
	var additionalArgument string
	flag.StringVar(&additionalArgument, "a", "", "Argument for credulous/sceptical reasoning")

	// full path to clingo solver
	var clingoPath string
	flag.StringVar(&clingoPath, "c", "/usr/bin/clingo", "Full path to clingo executable")

	// full path to diamond encodings
	var encPath string
	flag.StringVar(&encPath, "d", "enc/", "Full path to diamond encodings directory")

	// initialize the function that will later prepend encodings with their directory path
	Encodify := Prepend(&encPath)

	// verbosity
	var quiet bool
	flag.BoolVar(&quiet, "q", false, "Quiet mode; suppress all output except for models and satisfiability status")

	// read input and set values
	flag.Parse()

	// check for coherence: is there an input file name?
	var instanceFileName string

	if flag.NArg() < 1 {

		// if no instance was specified, return an error message and exit
		fmt.Println("goDIAMOND v0.1.0")
		fmt.Println("Quick usage: diamond -<semantics> <instance>")
		fmt.Println("Further commands:")
		flag.PrintDefaults()
		
		tooFew := errors.New("Fatal error: No instance file name specified!")
		log.Fatal(tooFew)
	}

	if flag.NArg() > 1 {

		// if more than one argument was given, return an error message and exit
		fmt.Println("goDIAMOND v0.1.0")
		fmt.Println("Quick usage: diamond -<semantics> <instance>")
		fmt.Println("Further commands:")
		flag.PrintDefaults()

		tooMany := errors.New(fmt.Sprintf("Fatal error: Too many arguments: %s", strings.Join(flag.Args(), " ")))
		log.Fatal(tooMany)
	}

	// get instance file name (unique non-flagged argument)
	instanceFileName = flag.Arg(0)

	// check for coherence: does the input file exist?
	file, err := os.Open(instanceFileName) // For read access.
	if err != nil {
		log.Fatal(err)
	} else {
		file.Close()
	}
	
	// check for coherence: input formats
	if ( pf.Active || bi.Active || af.Active ) {

		// if a non-default input format is activated, deactivate the default one
		fn.Active = false
	}
	
	if ( (fn.Active && bi.Active) || (fn.Active && af.Active) || (bi.Active && af.Active) ) {

		// if more than one non-default input format is activated, complain and exit
		err := errors.New("Fatal error: At most one input format can be used!")
		log.Fatal(err)
	}

	// check for coherence: reasoning modes
	if ( one.Active || cred.Active || scep.Active ) {

		// if a non-default reasoning mode is activated, deactivate the default one
		all.Active = false
	}
	
	if ( (one.Active && cred.Active) || (one.Active && scep.Active) || (cred.Active && scep.Active) ) {

		// if more than one non-default reasoning mode is activated, complain and exit
		err := errors.New("Fatal error: At most one reasoning mode can be used!")
		log.Fatal(err)
	}

	// check for coherence: if credulous/sceptical reasoning requires an argument
	if ( cred.Active || scep.Active ) && additionalArgument == "" {

		// if the argument (via -a) is not given, complain and exit
		err := errors.New("Fatal error: Argument whose acceptance should be checked must be specified by the -a flag!")
		log.Fatal(err)
	}

	// check if encodings path ends in "/" and add one if not
	if !strings.HasSuffix(encPath, "/") {

		encPath = string(append([]byte(encPath), '/'))
	}

	////////////////////////////////////////////////////////////////////////////////
	// now for the solving part

	// figure out what input format and what reasoning mode we are dealing with

	var format *InputFormat

	for i := range formats {

		if formats[i].Active {

			format = formats[i]
		}
	}

	var mode *ReasoningMode

	for i := range modes {

		if modes[i].Active {

			mode = modes[i]
		}
	}

	// figure out whether solver errors should be passed along to the user
	var errorChannel io.Writer
	if !quiet {

		errorChannel = os.Stderr
	} else {

		errorChannel = nil
	}

	// now solve for the chosen semantics
	mode.SetQueryTempFile(additionalArgument)

	// if no semantics has been specified, complain
	var someSemantics bool

	for i := range semantics {

		// check if the semantics is supposed to be computed
		if semantics[i].Compute {

			someSemantics = true

			solverArgs := append(mode.SolverCallArguments,
				Encodify(format.TransformationEncodingFileName),
				Encodify(format.OperatorEncodingFileName),
				Encodify(semantics[i].EncodingFileName),
				Encodify(mode.OutputEncodingFileName),
				instanceFileName)

			command := exec.Cmd{
				Path: clingoPath,
				Args: append(solverArgs, mode.QueryTempFileNames()...),
				Env: nil,
				Dir: "",
				Stdin: os.Stdin,
				Stderr: errorChannel,
				Stdout: os.Stdout}

			if !quiet { fmt.Println("--------------------------------------------------------------------------------") }
			if !quiet { fmt.Println("semantics:", semantics[i].Name) }
			if !quiet { fmt.Println("reasoning mode:", mode.CommandLineDescription) }
			if !quiet { fmt.Println("input format:", format.Name) }
			if !quiet { fmt.Println("Solver call:", command.Path, strings.Join(command.Args[1:], " ")) }
			if !quiet { fmt.Println("--------------------------------------------------------------------------------") }
			command.Run()
			if !quiet { fmt.Println("--------------------------------------------------------------------------------") }
		}
	}

	// remove temporary file if present
	mode.CleanUp()
	
	if !someSemantics {
		err := errors.New("Fatal error: No semantics specified!")
		log.Fatal(err)
	}
}
