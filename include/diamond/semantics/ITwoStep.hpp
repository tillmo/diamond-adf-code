#ifndef DIAMOND_ITWOSTEP_HPP
#define DIAMOND_ITWOSTEP_HPP

#include <clingo/clingocontrol.hh>

namespace diamond{
class ITwoStep{
protected:
  ClingoLib* partTwo;
  int model = 0;
  bool handleResult(const Gringo::Model& m);
public:
  void twostepsolve(ClingoLib& lib1, ClingoLib& lib2);
};
}

#endif /* DIAMOND_ITWOSTEP_HPP */
