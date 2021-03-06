#include <diamond/semantics/SemiModel.hpp>

bool diamond::SemiModel::needsFunc()
{
  return true;
}

void diamond::SemiModel::solve()
{
  // clingo 1
  std::vector<char const *> args{"clingo"};
  args.push_back("0");
  args.push_back(nullptr);
  DefaultGringoModule module;
  Gringo::Scripts scripts(module);
  ClingoLib lib(scripts, args.size() - 2, args.data());
  appOpt->getProgInstance(this,lib);

  //clingo 2
  std::vector<char const *> args2{"clingo"};
  if (appOpt->getEnumerate())
    args2.push_back("0");
  args2.push_back(nullptr);
  DefaultGringoModule module2;
  Gringo::Scripts scripts2(module2);
  ClingoLib lib2(scripts2, args2.size() - 2, args2.data());

  //addoperators
  this->addOperator(lib);

  //addencodings
  std::string cmp =
    #include DIA_ENC_CMP
      ;
  std::string show =
    #include DIA_ENC_SHOW
      ;

  lib.add("encoding",{},cmp);
  lib.add("encoding",{},show);
  lib.ground({{"base",{}},{"operator",{}},{"encoding",{}}},nullptr);

  std::string rmax =
    #include DIA_ENC_RMAX
      ;
  lib2.add("base",{},rmax);
  lib2.add("base",{},show);
  this->twostepsolve(lib,lib2);
  lib2.solve(std::bind(&diamond::SemiModel::printResult,this,std::placeholders::_1),{});
}
