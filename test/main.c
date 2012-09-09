#include "cfunc.h"

#include "mruby.h"
#include "mruby/dump.h"
#include "mruby/proc.h"
#include "mruby/compile.h"
#include "mobiruby_common.h"

struct mrb_state_ud {
    struct cfunc_state cfunc_state;
};


void
init_unittest(mrb_state *mrb);

void
init_mobi_common_test(mrb_state *mrb);


int main(int argc, char *argv[])
{
    mrb_state *mrb = mrb_open();
    mrb->ud = malloc(sizeof(struct mrb_state_ud));

    cfunc_state_offset = cfunc_offsetof(struct mrb_state_ud, cfunc_state);
    init_cfunc_module(mrb);
    init_mobiruby_common_module(mrb);

    init_unittest(mrb);
    if (mrb->exc) {
        mrb_p(mrb, mrb_obj_value(mrb->exc));
    }

    init_mobi_common_test(mrb);
    if (mrb->exc) {
        mrb_p(mrb, mrb_obj_value(mrb->exc));
    }
}


struct STest {
    int8_t x;
    int16_t y;
    int32_t z;
};


struct STest2 {
    struct STest s;
    double xx;
};


struct STest cfunc_test_func1(struct STest val) {
    val.z = val.x + val.y;
    return val;
};


struct STest2 cfunc_test_func2(struct STest2 val) {
    val.xx = (double)(val.s.x + val.s.y) / val.s.z;
    return val;
};


int cfunc_test_func3(int (*func)(int, int)) {
    return func(10, 20);
}
