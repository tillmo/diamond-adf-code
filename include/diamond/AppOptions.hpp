#ifndef DIAMOND_APPOPTIONS_HPP
#define DIAMOND_APPOPTIONS_HPP

#include <qt/QtCore/QFile>
#include <qt/QtCore/QFileInfo>
#include <diamond/InitException.hpp>
#include <clingo/clingocontrol.hh>
#include <diamond/semantics/ISemantics.hpp>

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
protected:
  int verbosity;
  bool enumerate;
  QFileInfo instance;
  int inputformat;
  bool transformToFun = false;
  std::vector<diamond::ISemantics*> semantics;
public:
  AppOptions();
  AppOptions(const int& verbosity, const std::string& instance, const bool& enumerate, int& inputformat);
  static diamond::InputFormat getInputFormat(const std::string& inputformat, const std::vector<std::string>& allowedVals);
  static const std::vector<std::string> ALLOWEDVALS;
  void addSemantics(diamond::ISemantics* semantics);
  int getVerbosity() const;
  bool getEnumerate() const;
  QFileInfo getInstance() const;
  int getInputformat() const;
};
}

#endif /* DIAMOND_APPOPTIONS_HPP */
