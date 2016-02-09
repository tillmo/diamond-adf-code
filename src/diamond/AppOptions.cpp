#include <diamond/AppOptions.hpp>

#include <iostream>

int diamond::AppOptions::getVerbosity() const
{
  return verbosity;
}

bool diamond::AppOptions::getEnumerate() const
{
  return enumerate;
}

QFileInfo diamond::AppOptions::getInstance() const
{
  return instance;
}

diamond::AppOptions::AppOptions(const int& verbosity, const std::string& instance, const bool& enumerate, int& inputformat):instance(QString::fromStdString(instance))
{
  this->verbosity = verbosity;
  this->enumerate = enumerate;
  this->inputformat = inputformat;
  if (!(this->instance.exists() && this->instance.isFile()))
    throw InitException("Instance " + instance + " does not exist!");
}

diamond::InputFormat diamond::AppOptions::getInputFormat(const std::string& inputformat, const std::vector<std::string>& allowedVals){
  int pos = std::find(allowedVals.begin(),allowedVals.end(),inputformat) - allowedVals.begin();
  if (pos >= allowedVals.size())
    throw InitException("This input format does not exist for Diamond");
  return InputFormat(pos);
}

void diamond::AppOptions::addSemantics(ISemantics* semantics)
{
  if (semantics->needsFunc() && this->inputformat == diamond::InputFormat::PF)
    this->transformToFun = true;
  this->semantics.push_back(semantics);
}

int diamond::AppOptions::getInputformat() const
{
  return inputformat;
}

const std::vector<std::string> diamond::AppOptions::ALLOWEDVALS ({"auto","bipolar","pf","fr","pr","tb","af"});
