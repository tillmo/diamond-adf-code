#ifndef DIAMOND_ISEMANTICS_HPP
#define DIAMOND_ISEMANTICS_HPP

#include <diamond/AppOptions.hpp>


namespace diamond{
//forward declarations
class AppOptions;

class ISemantics{
protected:
  diamond::AppOptions* appOpt;
  bool printResult(const Gringo::Model& m);
public:
  ISemantics(diamond::AppOptions* appOpt):appOpt(appOpt){}
  virtual void solve() = 0;
  virtual bool needsFunc() = 0;
  virtual ~ISemantics(){}
};
}

#endif /* DIAMOND_ISEMANTICS_HPP */
