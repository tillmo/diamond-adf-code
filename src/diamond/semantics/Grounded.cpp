#include <diamond/semantics/Grounded.hpp>

bool diamond::Grounded::needsFunc()
{
  return true;
}

void diamond::Grounded::solve()
{
  std::vector<char const *> args{"clingo"};
  args.push_back(nullptr);
  DefaultGringoModule module;
  Gringo::Scripts scripts(module);
  ClingoLib lib(scripts, args.size() - 2, args.data());
  appOpt->getProgInstance(this,lib);

  //addoperators
  this->addOperator(lib);

  //addencodings
  std::string tkk =
    #include DIA_ENC_TKK
      ;
  std::string grd =
    #include DIA_ENC_GRD
          ;
  std::string show =
    #include DIA_ENC_SHOW
      ;

  lib.add("encoding",{},tkk);
  lib.add("encoding",{},grd);
  lib.add("encoding",{},show);
  lib.ground({{"base",{}},{"operator",{}},{"encoding",{}}},nullptr);
  lib.solve(std::bind(&diamond::Grounded::printResult,this,std::placeholders::_1),{});
}
