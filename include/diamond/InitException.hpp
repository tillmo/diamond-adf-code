#ifndef DIAMOND_INITEXCEPTION_HPP
#define DIAMOND_INITEXCEPTION_HPP

namespace diamond{
class InitException : public std::runtime_error{


    // exception interface
public:
    InitException() : runtime_error(""){}
    InitException(const std::string& message) : runtime_error(message){}
private:
    std::string message;
};
}

#endif /* DIAMOND_INITEXCEPTION_HPP */
