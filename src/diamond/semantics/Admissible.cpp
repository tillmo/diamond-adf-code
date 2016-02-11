#include <diamond/semantics/Admissible.hpp>

bool diamond::Admissible::needsFunc()
{
  return true;
}

void diamond::Admissible::solve()
{
  std::vector<char const *> args{"clingo"};
  if (appOpt->getEnumerate())
    args.push_back("0");
  args.push_back(nullptr);
  DefaultGringoModule module;
  Gringo::Scripts scripts(module);
  ClingoLib lib(scripts, args.size() - 2, args.data());
  appOpt->getProgInstance(this,lib);

  //addoperators
  this->addOperator(lib);

  //addencodings
  std::string adm =
    #include DIA_ENC_ADM
      ;
  std::string show =
    #include DIA_ENC_SHOW
      ;

  lib.add("encoding",{},adm);
  lib.add("encoding",{},show);
  lib.ground({{"base",{}},{"operator",{}},{"encoding",{}}},nullptr);
  lib.solve(std::bind(&diamond::Admissible::printResult,this,std::placeholders::_1),{});
}
