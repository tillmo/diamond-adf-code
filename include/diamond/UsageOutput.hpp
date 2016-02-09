#ifndef DIAMOND_USAGEOUTPUT_HPP
#define DIAMOND_USAGEOUTPUT_HPP

#include <tclap/ArgException.h>
#include <tclap/CmdLineInterface.h>
#include <tclap/CmdLineOutput.h>
#include <tclap/StdOutput.h>
#include <iostream>

namespace diamond{
class UsageOutput:public TCLAP::CmdLineOutput{


  // CmdLineOutput interface
public:
  void virtual usage(TCLAP::CmdLineInterface& c);
  void virtual version(TCLAP::CmdLineInterface& c);
  void virtual failure(TCLAP::CmdLineInterface& c, TCLAP::ArgException& e);
protected:
  inline void _shortUsage(TCLAP::CmdLineInterface& c, std::ostream& os) const;
  inline void _longUsage(TCLAP::CmdLineInterface& c, std::ostream& os) const;
  inline void _prettyprint(TCLAP::CmdLineInterface& c, const std::string& str, std::ostream& os, int maxlength, int indentlength, int offset=0, bool prettyindent=false) const;
private:
  static const int LINELENGTH = 80;
  static const int INDENT = 2;
};
}

#endif /* DIAMOND_USAGEOUTPUT_HPP */
