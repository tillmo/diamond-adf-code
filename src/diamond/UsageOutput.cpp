#include <diamond/UsageOutput.hpp>



void diamond::UsageOutput::usage(TCLAP::CmdLineInterface& c)
{
  std::cout << "USAGE:" << std::endl;
  _shortUsage(c,std::cout);
  std::cout << "WHERE:" << std::endl;
  _longUsage(c,std::cout);
}

void diamond::UsageOutput::version(TCLAP::CmdLineInterface& c)
{
  std::cout << c.getProgramName() << " " << c.getVersion() << std::endl;
}

void diamond::UsageOutput::failure(TCLAP::CmdLineInterface& c, TCLAP::ArgException& e)
{
  std::cerr << "PARSE ERROR: " << e.argId() << std::endl
            << "  " << e.error() << std::endl;
  if (c.hasHelpAndVersion()){
    std::cerr << "Brief USAGE:" << std::endl;
    _shortUsage(c,std::cerr);
    std::cerr << "For complete USAGE and HELP type: "
              << std::endl << "  " << c.getProgramName() << " --help" << std::endl;
  }else
    this->usage(c);
  exit(1);
}

void diamond::UsageOutput::_shortUsage(TCLAP::CmdLineInterface& c, std::ostream& os) const
{
  std::list<TCLAP::Arg*> argList = c.getArgList();
  TCLAP::XorHandler xorHandler = c.getXorHandler();
  std::vector<std::vector<TCLAP::Arg*>> xorList = xorHandler.getXorList();

  std::string s = c.getProgramName();

  // xor arguments
  for (int i=0; static_cast<unsigned int>(i) < xorList.size();i++){
    s += " {";
    //for (TCLAP::ArgVectorIterator it = xorList[i].begin(); it != xorList[i].end(); it++)
    for (auto& elem : xorList[i])
      s += elem->shortID() + "|";
    s[s.length()-1]='}';
  }

  // other arguments
  for (auto& elem : argList){
    if (!xorHandler.contains(elem))
      s += " " + elem->shortID();
  }

  _prettyprint(c,s,os,LINELENGTH,c.getProgramName().length()+1,INDENT,LINELENGTH/2 > c.getProgramName().length()+INDENT);
}

void diamond::UsageOutput::_longUsage(TCLAP::CmdLineInterface& c, std::ostream& os) const
{
  std::list<TCLAP::Arg*> argList = c.getArgList();
  TCLAP::XorHandler xorHandler = c.getXorHandler();
  std::vector<std::vector<TCLAP::Arg*>> xorList = xorHandler.getXorList();
  std::string indent(INDENT*2,' ');

  // other arguments (than xored ones)
  for (auto& elem : argList){
    if (!xorHandler.contains(elem)){
      //_prettyprint(c,elem->longID(),std::cout,LINELENGTH,0,INDENT);
      //_prettyprint(c,elem->getDescription(),std::cout,LINELENGTH,0,INDENT*2,true);
      if(elem->isValueRequired()){
        _prettyprint(c,elem->longID(), std::cout,LINELENGTH,0,INDENT);
        _prettyprint(c,elem->getDescription(),std::cout,LINELENGTH,0,INDENT*2,true);
      }else
        _prettyprint(c,elem->longID() + indent + elem->getDescription(),std::cout,LINELENGTH,elem->longID().length()+INDENT*2,INDENT,true);
    }
  }

  // xored arguments
  for (int i=0; static_cast<unsigned int>(i) < xorList.size(); i++){
    std::cout << std::endl;
    for (auto& elem : xorList[i]){
      if (!xorHandler.contains(elem))
        _prettyprint(c,elem->longID() + indent + elem->getDescription(),std::cout,LINELENGTH,elem->longID().length()+INDENT*2,INDENT,true);
    }
  }
}

void diamond::UsageOutput::_prettyprint(TCLAP::CmdLineInterface& c, const std::string& str, std::ostream& os, int maxlength, int indentlength, int offset, bool prettyindent) const
{
  std::string s(str);
  std::string indent(indentlength,' ');
  std::string offindent(offset, ' ');
  int pos = 0;
  while ((s.length() > maxlength && pos != std::string::npos)||s.find("\n")!=std::string::npos){
    pos = s.find("\n");
    if (pos == std::string::npos || pos > maxlength)
      pos = s.substr(0,maxlength).find_last_of(c.getDelimiter());
    if (pos == std::string::npos)
      pos = s.find_first_of(c.getDelimiter());
    if (pos != std::string::npos){
      os << offindent << s.substr(0,pos) << std::endl;
      s = s.substr(pos+1);
      if (prettyindent)
        s = indent + s;
    }
  }
  os << offindent << s << std::endl;
}
