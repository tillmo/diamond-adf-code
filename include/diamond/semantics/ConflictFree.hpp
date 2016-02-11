#ifndef DIAMOND_CONFLICTFREE_HPP
#define DIAMOND_CONFLICTFREE_HPP

#include <diamond/semantics/ISemantics.hpp>
#include <diamond/config.h>
#include <clingo/clingocontrol.hh>
#include <functional>

namespace diamond{
/**
 * @brief The Model class
 * one step call, no transformation neeeded
 */
class ConflictFree : public diamond::ISemantics{
protected:
public:
  ConflictFree (diamond::AppOptions* appOpt):ISemantics(appOpt){}
  // ISemantics interface
public:
  void solve();
  bool needsFunc();
};
}

#endif /* DIAMOND_CONFLICTFREE_HPP */
