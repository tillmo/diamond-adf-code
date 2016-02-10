#include <diamond/semantics/ISemantics.hpp>

bool diamond::ISemantics::printResult(const Gringo::Model& m)
{
  for (auto& atom : m.atoms(Gringo::Model::SHOWN))
    std::cout << atom << " ";
  std::cout << std::endl;
  return true;
}
