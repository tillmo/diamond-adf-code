#include <diamond/semantics/ConflictFree.hpp>

bool diamond::ConflictFree::needsFunc()
{
  return true;
}

void diamond::ConflictFree::solve()
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
  std::string cfi =
    #include DIA_ENC_CFI
      ;
  std::string show =
    #include DIA_ENC_SHOW
      ;
  lib.add("encoding",{},cfi);
  lib.add("encoding",{},show);
  lib.ground({{"base",{}},{"operator",{}},{"encoding",{}}},nullptr);
  lib.solve(std::bind(&diamond::ConflictFree::printResult,this,std::placeholders::_1),{});
}
