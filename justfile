default:
  @just --choose

unittest:
    nvim --headless -u tests/lua/minimal_init.lua -c "PlenaryBustedDirectory tests/lua/unittest"

integration:
    nvim --headless -u tests/lua/minimal_init.lua -c "PlenaryBustedDirectory tests/lua/integration"
