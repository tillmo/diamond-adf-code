#include <diamond/config.h>
#include <diamond/UsageOutput.hpp>
#include <tclap/CmdLine.h>
#include <iostream>
#include <functional>
#include <diamond/AppOptions.hpp>

#include <diamond/semantics/Model.hpp>

#include <clingo/clingocontrol.hh>

class Foo{
public:
  int i;
  Foo(const int& i){
    this->i = i;

  }

  bool mmh(Gringo::Model const &m){
    for (auto &atom : m.atoms(Gringo::Model::SHOWN)) {
      std::cout << atom << " ";
    }
    std::cout << this->i << std::endl;
    return true;
  }


};

void example1(){
  std::vector<char const *> args{"clingo", "0", nullptr};
  DefaultGringoModule module;
  Gringo::Scripts scripts(module);
  ClingoLib lib(scripts, args.size() - 2, args.data());

  lib.add("base", {}, "a :- not b. b :- not a.");
  lib.add("base2", {}, "c.");
  lib.ground({{"base", {}}}, nullptr);
  int i = 10;
  Foo foo(i);


  lib.solve(std::bind(&Foo::mmh, foo, std::placeholders::_1),{});
}

void example2(diamond::AppOptions& appop){
  std::vector<char const *> args{"clingo", "-e", "brave", nullptr};
  DefaultGringoModule module;
  Gringo::Scripts scripts(module);
  ClingoLib lib(scripts, args.size() - 2, args.data());

  std::string repr_change =
    #include DIA_ENC_REPR_CHANGE
      ;

  Foo foo(1);
  lib.load(appop.getInstance().absoluteFilePath().toStdString());
  lib.add("repr_change",{},repr_change);
  lib.ground({{"base",{}},{"repr_change",{}}},nullptr);

  lib.solve(std::bind(&Foo::mmh, foo, std::placeholders::_1),{});
}

int main(int argc, char**argv){
  try{
    using namespace TCLAP;
    CmdLine cmd(DIAMOND_NAME,' ',DIAMOND_VERSION);
    diamond::UsageOutput uOut;
    int iformat;
    cmd.setOutput(&uOut);
    ValueArg<int> verbosity("v","verbosity", "(default=1) controls the verbosity of DIAMOND, from 0 for only results to 2 with statistics",false,1,"0..2",cmd);
    UnlabeledValueArg<std::string> instance("Instance","Filename of the ADF instance",true,"instance.adf","Instance",cmd);
    SwitchArg sem_cfi("","cfi","compute the conflict-free interpretations",cmd);
    SwitchArg sem_nai("","nai","compute the naive interpretations",cmd);
    SwitchArg sem_stg("","stg","compute the stage interpretations",cmd);
    SwitchArg sem_sem("","sem","compute the semi-model interpretations",cmd);
    SwitchArg sem_mod("","mod","compute the two-valued models",cmd);
    SwitchArg sem_stm("","stm","compute the stable models",cmd);
    SwitchArg sem_grd("","grd","compute the grounded interpretations",cmd);
    SwitchArg sem_com("","com","compute the complete interpretations",cmd);
    SwitchArg sem_adm("","adm","compute the admissible interpretations",cmd);
    SwitchArg sem_prf("","prf","compute the preferred interpreteations",cmd);
    SwitchArg sem_all("","all","compute all interpreations for all semantics",cmd);
    SwitchArg enumerate("e","enum", "enumerate all interpretations",cmd);
    std::vector<std::string> allowedValues;
    allowedValues.reserve(diamond::AppOptions::ALLOWEDVALS.size());
    std::copy(diamond::AppOptions::ALLOWEDVALS.begin(),diamond::AppOptions::ALLOWEDVALS.end(),std::back_inserter(allowedValues));
    ValuesConstraint<std::string> allowedVals (allowedValues);
    ValueArg<std::string> inputformat("f","format","(default=auto)\ninstance input format of the acceptance functions, It may be bipolar, propositional formulas, functional representation, priorities, or theory bases, as well as being identified automatic (via file extension)",false,"auto",&allowedVals,cmd);
    cmd.parse(argc,argv);
    std::cout << instance.getValue() << std::endl;
    iformat = diamond::AppOptions::getInputFormat(inputformat.getValue(),allowedValues);
    diamond::AppOptions appoptions(verbosity.getValue(),instance.getValue(), enumerate.getValue(),iformat);

    if (sem_mod.getValue())
      appoptions.addSemantics(new diamond::Model(&appoptions));

    appoptions.solveSemantics();
  }catch(const TCLAP::ArgException& e){
    std::cerr << e.what() << std::endl;
  }catch(const diamond::InitException& e){
    std::cerr << e.what() << std::endl;
  }
}
