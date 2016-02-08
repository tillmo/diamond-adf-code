#include <diamond/config.h>
#include <diamond/UsageOutput.hpp>
#include <tclap/CmdLine.h>
#include <iostream>

int main(int argc, char**argv){
  try{
    using namespace TCLAP;
    CmdLine cmd(DIAMOND_NAME,' ',DIAMOND_VERSION);
    UsageOutput uOut;
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
    std::vector<std::string> allowedstrings = {"auto","bipolar","pf","fr","pr","tb"};
    ValuesConstraint<std::string> allowedVals (allowedstrings);
    ValueArg<std::string> inputformat("f","format","(default=auto)\ninstance input format of the acceptance functions, It may be bipolar, propositional formulas, functional representation, priorities, or theory bases, as well as being identified automatic (via file extension)",false,"auto",&allowedVals,cmd);
    cmd.parse(argc,argv);
    std::cout << instance.getValue() << std::endl;
  }catch(const TCLAP::ArgException& e){
    std::cerr << e.what() << std::endl;
  }
}
