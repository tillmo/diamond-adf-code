#include <diamond/semantics/Model.hpp>

bool diamond::Model::needsFunc()
{
  return false;
}

void diamond::Model::solve()
{
  std::vector<char const *> args{"clingo"};
  if (appOpt->getEnumerate())
    args.push_back("0");
  args.push_back(nullptr);
  DefaultGringoModule module;
  Gringo::Scripts scripts(module);
  ClingoLib lib(scripts, args.size() - 2, args.data());
  appOpt->getProgInstance(this,lib);


  // add encodings:
  switch (appOpt->getInputformat()){
  case diamond::InputFormat::AF:{
    std::string afop =
    #include DIA_ENC_AFOP
        ;
    std::string cmp =
    #include DIA_ENC_CMP
        ;
    std::string twoval =
    #include DIA_ENC_TWOVALUED
        ;
    lib.add("encoding",{},afop);
    lib.add("encoding",{},cmp);
    lib.add("encoding",{},twoval);
    break;
  }
  case diamond::InputFormat::TB:{
    std::string fmodel =
    #include DIA_ENC_FMODEL
        ;
    std::string tb2badf =
    #include DIA_ENC_TB2BADF
        ;
    lib.add("encoding",{},fmodel);
    lib.add("encoding",{},tb2badf);
    break;
  }
  case diamond::InputFormat::PR:
  case diamond::InputFormat::FR:{
    std::string base =
    #include DIA_ENC_BASE
        ;
    std::string cf =
    #include DIA_ENC_CF
        ;
    std::string model =
    #include DIA_ENC_MODEL
        ;
    lib.add("encoding",{},base);
    lib.add("encoding",{},cf);
    lib.add("encoding",{},model);
    break;
  }
  default:{
    std::string fmodel=
    #include DIA_ENC_FMODEL
        ;
    lib.add("encoding",{},fmodel);
    break;
  }
  }
  std::string show =
    #include DIA_ENC_SHOW
      ;
  lib.add("encoding",{},show);
  lib.ground({{"base",{}},{"encoding",{}}},nullptr);
  lib.solve(std::bind(&diamond::Model::printResult,this,std::placeholders::_1),{});
}
