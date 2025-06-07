default:
  @just --choose

unit-test:
    nvim --headless -u tests/lua/minimal_init.lua -c "PlenaryBustedDirectory tests/lua"
