#include <diamond/semantics/StableModel.hpp>

void diamond::StableModel::solve()
{
  std::vector<char const *> args{"clingo"};
  if (appOpt->getEnumerate())
    args.push_back("0");
  args.push_back(nullptr);
  DefaultGringoModule module;
  Gringo::Scripts scripts(module);
  ClingoLib lib(scripts, args.size() - 2, args.data());
  appOpt->getProgInstance(this,lib);

  //add encodings
  std::string base =
    #include DIA_ENC_BASE
      ;
  std::string cf =
    #include DIA_ENC_CF
      ;
  std::string model =
    #include DIA_ENC_MODEL
      ;
  std::string opsm =
    #include DIA_ENC_OPSM
      ;
  std::string tkk =
    #include DIA_ENC_TKK
      ;
  std::string stb =
    #include DIA_ENC_STB
      ;
  std::string show =
    #include DIA_ENC_SHOW
      ;

  lib.add("encoding",{},base);
  lib.add("encoding",{},cf);
  lib.add("encoding",{},model);
  lib.add("encoding",{},opsm);
  lib.add("encoding",{},tkk);
  lib.add("encoding",{},stb);
  lib.add("encoding",{},show);
  lib.ground({{"base",{}},{"encoding",{}}},nullptr);
  lib.solve(std::bind(&diamond::StableModel::printResult,this,std::placeholders::_1),{});
}

bool diamond::StableModel::needsFunc()
{
  return true;
}
