#include <diamond/semantics/Complete.hpp>

bool diamond::Complete::needsFunc()
{
  return true;
}

void diamond::Complete::solve()
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
  std::string cmp =
    #include DIA_ENC_CMP
      ;
  std::string show =
    #include DIA_ENC_SHOW
      ;
  lib.add("encoding",{},cmp);
  lib.add("encoding",{},show);
  lib.ground({{"base",{}},{"operator",{}},{"encoding",{}}},nullptr);
  lib.solve(std::bind(&diamond::Complete::printResult,this,std::placeholders::_1),{});
}
