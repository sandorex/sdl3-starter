#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest/doctest.h"

int add(int a, int b) {
    return a + b;
}

TEST_CASE("Sanity check") {
    CHECK(add(1, 2) == 3);
    CHECK(add(2, -2) == 0);
}
