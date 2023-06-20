The mocking structure for a class `Variable` in path
`tests/mocks/lib/CoolClass/VariableMocks.[h,cpp]` to the corresponding
`src/lib/CoolClass/Variable[h,cpp]` could look like this:
```c
// Variable.h
#pragma once
#include "CoolClass/Variable.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"

#define VARIABLE_MOCK VariableMock::instance(false)
#define VARIABLE_NICE_MOCK VariableMock::instance(true)

class VariableMock {
public:
  static VariableMock *instance(bool Nice = false);
  virtual ~VariableMock();
  void EvaluateAndClear();
  MOCK_METHOD0(VariableMock_Instance, Variable*());
  MOCK_METHOD0(VariableMock_Constructor_1,void());
  MOCK_METHOD0(VariableMock_Destructor,void());

  // MOCK_METHOD ++ CNT_ARGS ++ (Function in VariableMock.cpp, Return type(argument1,..));

protected:
  VariableMock();
  VariableMock(const VariableMock &);
  VariableMock & operator=(const VariableMock &);

private:
  static VariableMock * mpInstance;
};
```
```c
// Variable.cpp
#include <stdlib.h>
#include "mocks/lib/CoolClass/VariableMock.h"
using ::testing::NiceMock;
VariableMock * VariableMock::mpInstance = NULL;
VariableMock * VariableMock::instance(bool Nice) {
   if(mpInstance == NULL) {
      if(Nice) mpInstance = new NiceMock<VariableMock>();
      else mpInstance = new VariableMock();
   }
   return (mpInstance);
}
VariableMock::VariableMock() {}
VariableMock::~VariableMock() {}
void VariableMock::EvaluateAndClear() {
   delete mpInstance;
   mpInstance = NULL;
}
// Instantiations below
Variable* Variable::Instance() {
  return VARIABLE_MOCK->VariableMock_Instance();
}

Variable::Variable() {
  VARIABLE_MOCK->VariableMock_Constructor_1();
}

Variable::~Variable() {
  VARIABLE_MOCK->VariableMock_Destructor();
}

// Variable::Variable_function(..) {
// VARIABLE_MOCK->Mocked function name as declared in Variable.h
// }

// optionally use return
// Note, that static does not work.

```

Simplified (thus incorrect) usage. Note that `..` is to simplify arguments.
```c
  // Substitutions must come before actual calls
  // substitute return values
  EXPECT_CALL(*VARIABLE_NICE_MOCK, MockedMethod_1(_,_)).WillOnce(Invoke(&substitution1, &substitution2));
             Variable_Constructor_1(_,_)).WillOnce(Invoke(&substitution1, &substitution2));
  // no substitution
  EXPECT_CALL(*VARIABLE_NICE_MOCK, Variable_Constructor_2(_)).Times(3);
  std::unique_ptr<CoolClass> test_object(new CoolClass(..));
  test_object->AddVariable(..);
```

Make sure that all functions in namespace `Variable::` exist and that the
source is used or the library containing the mock linked. Also, make sure that
all functions in the mock `.cpp` are prefixed `Variable::`. Otherwise, there
will be bogus linker errors. Remind, that the mock must be first on the linker
line, so that it includes the necessary original symbols as needed. If the mock
is used as dependency from another mock, the other mock should be first on the
linker line.
