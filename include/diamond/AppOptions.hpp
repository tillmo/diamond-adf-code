#ifndef DIAMOND_APPOPTIONS_HPP
#define DIAMOND_APPOPTIONS_HPP

#include <functional>
#include <qt/QtCore/QFile>
#include <qt/QtCore/QFileInfo>
#include <diamond/InitException.hpp>
#include <clingo/clingocontrol.hh>
#include <diamond/semantics/ISemantics.hpp>
#include <diamond/config.h>
#include <sstream>

namespace diamond{
// forward declarations
class ISemantics;

enum InputFormat{
  AUTO = 0,
  BIPOLAR,
  PF,
  FR,
  PR,
  TB,
  AF
};

class AppOptions{
private:
  bool transformFirstModel;
protected:
  int verbosity;
  bool enumerate;
  QFileInfo instance;
  int inputformat;
  bool transformToFun = false;
  std::vector<diamond::ISemantics*> semantics;
  std::vector<std::string> functionalrepr;
  bool saveTransformResult(const Gringo::Model& m);
public:
  AppOptions();
  AppOptions(const int& verbosity, const std::string& instance, const bool& enumerate, int& inputformat);
  static diamond::InputFormat getInputFormat(const std::string& inputformat, const std::vector<std::string>& allowedVals);
  static const std::vector<std::string> ALLOWEDVALS;
  void addSemantics(diamond::ISemantics* semantics);
  void solveSemantics();
  void transformFunc();
  void getProgInstance(diamond::ISemantics* caller, ClingoLib& lib);
  int getVerbosity() const;
  bool getEnumerate() const;
  QFileInfo getInstance() const;
  int getInputformat() const;
  ~AppOptions();
};
}

#endif /* DIAMOND_APPOPTIONS_HPP */
