#include <diamond/semantics/ISemantics.hpp>

bool diamond::ISemantics::printResult(const Gringo::Model& m)
{
  for (auto& atom : m.atoms(Gringo::Model::SHOWN))
    std::cout << atom << " ";
  std::cout << std::endl;
  return true;
}

void diamond::ISemantics::addOperator(ClingoLib& lib)
{
  switch(appOpt->getInputformat()){
  case diamond::InputFormat::AF:{
    std::string afop =
    #include DIA_ENC_AFOP
        ;
    lib.add("operator",{},afop);
    break;
  }
  case diamond::InputFormat::BIPOLAR:{
    std::string bop =
    #include DIA_ENC_BOP
        ;
    lib.add("operator", {}, bop);
    break;
  }
  case diamond::InputFormat::TB:{
    std::string bop=
    #include DIA_ENC_BOP
        ;
    std::string tb2badf =
    #include DIA_ENC_TB2BADF
        ;
    lib.add("operator",{},bop);
    lib.add("operator",{},tb2badf);
    break;
  }
  default:{
    std::string base =
    #include DIA_ENC_BASE
        ;
    std::string op =
    #include DIA_ENC_OP
        ;
    lib.add("operator",{},base);
    lib.add("operator",{},op);
  }
  }
}
