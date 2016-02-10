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

void diamond::AppOptions::transformFunc()
{
  this->transformToFun = true;
  std::vector<char const *> args{"clingo", "0", nullptr};
  DefaultGringoModule module;
  Gringo::Scripts scripts(module);
  ClingoLib lib(scripts, args.size() - 2, args.data());

  std::string repr_change =
    #include DIA_ENC_REPR_CHANGE
      ;

  lib.load(this->getInstance().absoluteFilePath().toStdString());
  lib.add("repr_change",{},repr_change);
  lib.ground({{"base",{}},{"repr_change",{}}},nullptr);
  this->transformFirstModel = true;
  lib.solve(std::bind(&AppOptions::saveTransformResult,this,std::placeholders::_1),{});
}

void diamond::AppOptions::getProgInstance(ISemantics* caller, ClingoLib& lib)
{
  if (this->inputformat == diamond::InputFormat::PR || (caller->needsFunc() && this->inputformat == diamond::InputFormat::PF)){
    // functional representation needed
    for (auto& atom : this->functionalrepr)
      lib.add("base",{},atom);
  }else // file can be loaded
    lib.load(this->getInstance().absoluteFilePath().toStdString());
}

bool diamond::AppOptions::saveTransformResult(const Gringo::Model& m)
{
  std::stringstream ss;
  std::string atomval;
  for (auto &atom : m.atoms(Gringo::Model::SHOWN)){
    ss.str(std::string()); //resetting ss
    ss << atom;
    atomval = ss.str();
    if (transformFirstModel || (atomval[0]!='s' && atomval[0]!='l'))
      this->functionalrepr.push_back(atomval + ".");
  }
  this->transformFirstModel = false;
  return true;
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
  if (((semantics->needsFunc() && this->inputformat == diamond::InputFormat::PF)
       || this->inputformat == diamond::InputFormat::PR)
      && !this->transformToFun)
    transformFunc();
  this->semantics.push_back(semantics);
}

void diamond::AppOptions::solveSemantics()
{
  for (auto& semantics : this->semantics)
    semantics->solve();
}

int diamond::AppOptions::getInputformat() const
{
  return inputformat;
}

diamond::AppOptions::~AppOptions()
{
  for (auto& s : this->semantics)
    delete s;
}

const std::vector<std::string> diamond::AppOptions::ALLOWEDVALS ({"auto","bipolar","pf","fr","pr","tb","af"});
