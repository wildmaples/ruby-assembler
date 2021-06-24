require_relative "parser"
require_relative "code"
require_relative "symbol_table"

class Assembler
  def initialize(input_file)
    @parser = Parser.new(input_file)
    @code = Code.new
    @symbol_table = SymbolTable.new
    add_predefined_symbols
  end

  PREDEFINED_SYMBOLS = {
    "SP" => 0,
    "LCL" => 1,
    "ARG" => 2,
    "THIS" => 3,
    "THAT" => 4,
    "R0" => 0,
    "R1" => 1,
    "R2" => 2,
    "R3" => 3,
    "R4" => 4,
    "R5" => 5,
    "R6" => 6,
    "R7" => 7,
    "R8" => 8,
    "R9" => 9,
    "R10" => 10,
    "R11" => 11,
    "R12" => 12,
    "R13" => 13,
    "R14" => 14,
    "R15" => 15,
    "SCREEN" => 16384,
    "KBD" => 24576,
  }

  def add_predefined_symbols
    PREDEFINED_SYMBOLS.each do |symbol, address|
      @symbol_table.add_entry(symbol, address)
    end
  end

  def assemble
    binary_instructions = []
    while @parser.has_more_commands?
      @parser.advance
      if @parser.command_type == :A_COMMAND
        a_symbol = @parser.symbol 
        
        if @symbol_table.contains?(a_symbol)
          a_symbol = @symbol_table.get_address(a_symbol)
        end
        
        binary_instructions << (sprintf("0%015b", a_symbol))
      elsif @parser.command_type == :C_COMMAND
        comp, dest, jump = @parser.comp, @parser.dest, @parser.jump
        comp, dest, jump = @code.comp(comp), @code.dest(dest), @code.jump(jump)
        binary_instructions << "111#{comp}#{dest}#{jump}"
      end
    end

    binary_instructions.join("\n")
  end
end