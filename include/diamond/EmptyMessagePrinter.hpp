#include <clingo/clingocontrol.hh>

namespace diamond{
class EmptyMessagePrinter : public Gringo::MessagePrinter {


  // MessagePrinter interface
public:
  bool check(Gringo::Errors id)
  {
    return true;
  }
  bool check(Gringo::Warnings id)
  {
    return true;
  }
  bool hasError() const
  {
    return false;
  }
  void enable(Gringo::Warnings id)
  {
    ;
  }
  void disable(Gringo::Warnings id)
  {
    ;
  }
  void print(const std::__cxx11::string& msg)
  {
    ;
  }
};
}
