#include <diamond/semantics/ITwoStep.hpp>
#include <sstream>


bool diamond::ITwoStep::handleResult(const Gringo::Model& m)
{
  std::stringstream ss;
  std::string atomval;
  for (auto& atom : m.atoms(Gringo::Model::SHOWN)){
    ss.str(std::string()); //resetting ss
    ss << atom;
    atomval =  ss.str();
    atomval = atomval.substr(0,atomval.length()-1) + ","  + std::to_string(model) + ").";
    partTwo->add("base",{},atomval);
  }
  model++;
  return true;
}

void diamond::ITwoStep::twostepsolve(ClingoLib& lib1, ClingoLib& lib2)
{
  this->partTwo = &lib2;
  lib1.solve(std::bind(&diamond::ITwoStep::handleResult,this,std::placeholders::_1),{});
  lib2.ground({{"base",{}}},nullptr);
}
