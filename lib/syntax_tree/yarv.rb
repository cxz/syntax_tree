# frozen_string_literal: true

class SyntaxTree < Ripper
  # A calldata object represents the metadata necessary to handle a method
  # call.
  class CallData
    ARGS_SIMPLE = "ARGS_SIMPLE"
    FCALL = "FCALL"
    SUPER = "SUPER"
    VCALL = "VCALL"
    ZSUPER = "ZSUPER"

    attr_reader :mid, :argc, :flags

    def initialize(mid, argc, flags)
      @mid = mid
      @argc = argc
      @flags = flags
    end

    def inspect
      name = mid ? "mid:#{mid}, " : nil
      "<calldata!#{name}argc:#{argc}, #{flags}>"
    end
  end

  module Insn
    # anytostring
    class AnyToString
      def inspect = "anytostring"
      def width = 1
    end

    # branchif
    class BranchIf
      attr_accessor :index

      def initialize(index)
        @index = index
      end

      def inspect = "%-38s #{index}" % "branchif"
      def width = 2
    end

    # branchnil
    class BranchNil
      attr_accessor :index

      def initialize(index)
        @index = index
      end

      def inspect = "%-38s #{index}" % "branchnil"
      def width = 2
    end

    # branchunless
    class BranchUnless
      attr_accessor :index

      def initialize(index)
        @index = index
      end

      def inspect = "%-38s #{index}" % "branchunless"
      def width = 2
    end

     # concatstrings
     class ConcatStrings
      attr_reader :num

      def initialize(num)
        @num = num
      end

      def inspect = "%-38s #{num}" % "concatstrings"
      def width = 2
    end

    # defineclass
    class DefineClass
      attr_reader :name, :iseq, :flags

      def initialize(name, iseq, flags)
        @name = name
        @iseq = iseq
        @flags = flags
      end

      def inspect = "%-38s #{name.inspect}, #{iseq.name}, #{flags}" % "defineclass"
      def width = 4
    end

    # dup
    class Dup
      def inspect = "dup"
      def width = 1
    end

    # getglobal
    class GetGlobal
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def inspect = "%-38s #{name.inspect}" % "getglobal"
      def width = 2
    end

    # getlocal
    class GetLocal
      attr_reader :name, :level

      def initialize(name, level)
        @name = name
        @level = level
      end

      def inspect
        prefix =
          case level
          when 0 then "getlocal_WC_0"
          when 1 then "getlocal_WC_1"
          else
            "getlocal"
          end

        "%-38s #{name}@#{level}" % prefix
      end

      def width = 2
    end

    # invokesuper
    class InvokeSuper
      attr_reader :calldata

      def initialize(calldata)
        @calldata = calldata
      end

      def inspect = "%-38s #{calldata.inspect}" % "invokesuper"
      def width = 2
    end

    # jump
    class Jump
      attr_accessor :index

      def initialize(index)
        @index = index
      end

      def inspect = "%-38s #{index}" % "jump"
      def width = 2
    end

    # leave
    class Leave
      def inspect = "leave"
      def width = 1
    end

    # objtostring
    class ObjToString
      attr_reader :calldata

      def initialize(calldata)
        @calldata = calldata
      end

      def inspect = "%-38s #{calldata.inspect}" % "objtostring"
      def width = 2
    end

    # opt_div
    class OptDiv
      attr_reader :calldata

      def initialize(calldata)
        @calldata = calldata
      end

      def inspect = "%-38s #{calldata.inspect}" % "opt_div"
      def width = 2
    end

    # opt_minus
    class OptMinus
      attr_reader :calldata

      def initialize(calldata)
        @calldata = calldata
      end

      def inspect = "%-38s #{calldata.inspect}" % "opt_minus"
      def width = 2
    end

    # opt_mult
    class OptMult
      attr_reader :calldata

      def initialize(calldata)
        @calldata = calldata
      end

      def inspect = "%-38s #{calldata.inspect}" % "opt_mult"
      def width = 2
    end

    # opt_plus
    class OptPlus
      attr_reader :calldata

      def initialize(calldata)
        @calldata = calldata
      end

      def inspect = "%-38s #{calldata.inspect}" % "opt_plus"
      def width = 2
    end

    # opt_send_without_block
    class OptSendWithoutBlock
      attr_reader :calldata

      def initialize(calldata)
        @calldata = calldata
      end

      def inspect = "%-38s #{calldata.inspect}" % "opt_send_without_block"
      def width = 2
    end

    # pop
    class Pop
      def inspect = "pop"
      def width = 1
    end

    # putnil
    class PutNil
      def inspect = "putnil"
      def width = 1
    end

    # putobject
    class PutObject
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def inspect = "%-38s #{value.inspect}" % "putobject"
      def width = 2
    end

    # putobject_INT2FIX_0_
    class PutObjectInt2Fix0
      def inspect = "putobject_INT2FIX_0_"
      def width = 1
    end

    # putobject_INT2FIX_1_
    class PutObjectInt2Fix1
      def inspect = "putobject_INT2FIX_1_"
      def width = 1
    end

    # putself
    class PutSelf
      def inspect = "putself"
      def width = 1
    end

    # putspecialobject
    class PutSpecialObject
      VMCORE = 1
      CBASE = 2
      CONST_BASE = 3

      attr_reader :value

      def initialize(value)
        @value = value
      end

      def inspect = "%-38s #{value}" % "putspecialobject"
      def width = 2
    end

    # setlocal
    class SetLocal
      attr_reader :name, :level

      def initialize(name, level)
        @name = name
        @level = level
      end

      def inspect
        prefix =
          case level
          when 0 then "setlocal_WC_0"
          when 1 then "setlocal_WC_1"
          else
            "setlocal"
          end

        "%-38s #{name}@#{level}" % prefix
      end

      def width = 2
    end
  end

  class ISeq
    attr_reader :name, :parent, :children
    attr_reader :insns, :size, :locals

    def initialize(name, parent = nil)
      @name = name
      @parent = nil
      @children = []

      @insns = []
      @size = 0
      @locals = []
    end

    def child(name)
      ISeq.new(name, self).tap { |iseq| children << iseq }
    end

    def <<(insn)
      insns << insn
      @size += insn.width
    end

    def local(name)
      locals << name
    end

    def local?(name)
      locals.include?(name)
    end

    def inspect
      output = ["=== disasm: #<ISeq:#{name}@<compiled>:1"]

      index = 0
      insns.each do |insn|
        output << "%04d #{insn.inspect}" % index
        index += insn.width
      end

      output += children.map { |child| "\n#{child.inspect}" }
      output.join("\n")
    end
  end

  def self.compile(source)
    parse(source).compile
  end

  class Alias
    def compile(iseq)
      iseq << Insn::PutSpecialObject.new(Insn::PutSpecialObject::VMCORE)
      iseq << Insn::PutSpecialObject.new(Insn::PutSpecialObject::CBASE)
      left.compile(iseq)
      right.compile(iseq)
      iseq << Insn::OptSendWithoutBlock.new(CallData.new("core#set_method_alias", 3, "ARGS_SIMPLE"))
    end
  end

  class Assign
    def compile(iseq)
      value.compile(iseq)

      case target
      in VarField[{ value: name }]
        iseq.local(name)
        iseq << Insn::SetLocal.new(name, 0)
      end
    end
  end

  class Binary
    def compile(iseq)
      case operator
      in :+
        left.compile(iseq)
        right.compile(iseq)
        iseq << Insn::OptPlus.new(CallData.new(operator, 1, "ARGS_SIMPLE"))
      in :-
        left.compile(iseq)
        right.compile(iseq)
        iseq << Insn::OptMinus.new(CallData.new(operator, 1, "ARGS_SIMPLE"))
      in :*
        left.compile(iseq)
        right.compile(iseq)
        iseq << Insn::OptMult.new(CallData.new(operator, 1, "ARGS_SIMPLE"))
      in :/
        left.compile(iseq)
        right.compile(iseq)
        iseq << Insn::OptDiv.new(CallData.new(operator, 1, "ARGS_SIMPLE"))
      in :"||"
        left.compile(iseq)
        iseq << Insn::Dup.new

        branch = Insn::BranchIf.new(nil)
        iseq << branch

        iseq << Insn::Pop.new
        right.compile(iseq)

        branch.index = iseq.size
      in :"&&"
        left.compile(iseq)
        iseq << Insn::Dup.new

        branch = Insn::BranchUnless.new(nil)
        iseq << branch

        iseq << Insn::Pop.new
        right.compile(iseq)

        branch.index = iseq.size
      end
    end
  end

  class BodyStmt
    def compile(iseq)
      rescue_clause => nil
      else_clause => nil
      ensure_clause => nil

      statements.compile(iseq)
    end
  end

  class Call
    def compile(iseq)
      receiver.compile(iseq)

      name = message == :call ? :call : message.value
      send = Insn::OptSendWithoutBlock.new(CallData.new(name, 0, "ARGS_SIMPLE"))

      if operator in Op[value: "&."]
        iseq << Insn::Dup.new

        branch = Insn::BranchNil.new(nil)
        iseq << branch
        iseq << send

        branch.index = iseq.size
      else
        iseq << send
      end
    end
  end

  class ClassDeclaration
    def compile(iseq)
      iseq << Insn::PutSpecialObject.new(Insn::PutSpecialObject::CONST_BASE)

      if superclass
        superclass.compile(iseq)
      else
        iseq << Insn::PutNil.new
      end

      case constant
      in ConstRef[constant: { value: }]
        child = iseq.child("<class:#{value}>")

        bodystmt.compile(child)
        child << Insn::PutNil.new
        child << Insn::Leave.new

        iseq << Insn::DefineClass.new(value.to_sym, child, 0)
      end
    end
  end

  class Else
    def compile(iseq)
      statements.compile(iseq)
    end
  end

  class FloatLiteral
    def compile(iseq)
      iseq << Insn::PutObject.new(value.to_f)
    end
  end

  class If
    def compile(iseq)
      predicate.compile(iseq)

      branch = Insn::BranchUnless.new(nil)
      iseq << branch

      statements.compile(iseq)

      if consequent
        iseq << Insn::Pop.new

        jump = Insn::Jump.new(nil)
        iseq << jump
        branch.index = iseq.size

        consequent.compile(iseq)
        iseq << Insn::Pop.new

        jump.index = iseq.size
      else
        branch.index = iseq.size
      end
    end
  end

  class IfMod
    def compile(iseq)
      predicate.compile(iseq)
      branch = Insn::BranchUnless.new(nil)
      iseq << branch

      statement.compile(iseq)
      iseq << Insn::Pop.new
      branch.index = iseq.size
    end
  end

  class Imaginary
    def compile(iseq)
      iseq << Insn::PutObject.new(value.to_c)
    end
  end

  class Int
    def compile(iseq)
      case coerced = value.to_i
      when 0
        iseq << Insn::PutObjectInt2Fix0.new
      when 1
        iseq << Insn::PutObjectInt2Fix1.new
      else
        iseq << Insn::PutObject.new(coerced)
      end
    end
  end

  class Paren
    def compile(iseq)
      contents.compile(iseq)
    end
  end

  class Program
    def compile
      iseq = ISeq.new("<compiled>")
      statements.compile(iseq)
      iseq << Insn::Leave.new
      iseq
    end
  end

  class RationalLiteral
    def compile(iseq)
      iseq << Insn::PutObject.new(value.to_r)
    end
  end

  class Statements
    def compile(iseq)
      body.each do |node|
        node.compile(iseq)
      end
    end
  end

  class StringConcat
    def compile(iseq)
      left.compile(iseq)
      right.compile(iseq)
      iseq << Insn::ConcatStrings.new(2)
    end
  end

  class StringDVar
    def compile(iseq)
      case variable
      in VarRef[value: GVar[value: name]]
        iseq << Insn::GetGlobal.new(name.to_sym)
      end

      iseq << Insn::Dup.new
      iseq << Insn::ObjToString.new(CallData.new("to_s", 0, "FCALL|ARGS_SIMPLE"))
      iseq << Insn::AnyToString.new
    end
  end

  class StringEmbExpr
    def compile(iseq)
      statements.compile(iseq)
      iseq << Insn::Dup.new
      iseq << Insn::ObjToString.new(CallData.new("to_s", 0, "FCALL|ARGS_SIMPLE"))
      iseq << Insn::AnyToString.new
    end
  end

  class StringLiteral
    def compile(iseq)
      parts.each { |part| part.compile(iseq) }
      iseq << Insn::ConcatStrings.new(parts.length) if parts.length > 1
    end
  end

  class SymbolLiteral
    def compile(iseq)
      iseq << Insn::PutObject.new(value.value.to_sym)
    end
  end

  class TStringContent
    def compile(iseq)
      iseq << Insn::PutObject.new(value)
    end
  end

  class UnlessMod
    def compile(iseq)
      predicate.compile(iseq)
      branch = Insn::BranchIf.new(nil)
      iseq << branch

      statement.compile(iseq)
      iseq << Insn::Pop.new
      branch.index = iseq.size
    end
  end

  class VarRef
    def compile(iseq)
      case value
      in Ident[value:] if iseq.local?(value)
        iseq << Insn::GetLocal.new(value, 0)
      end
    end
  end

  class VCall
    def compile(iseq)
      iseq << Insn::PutSelf.new
      iseq << Insn::OptSendWithoutBlock.new(CallData.new(value.value, 0, "FCALL|VCALL|ARGS_SIMPLE"))
    end
  end

  class VoidStmt
    def compile(iseq)
    end
  end

  class XStringLiteral
    def compile(iseq)
      iseq << Insn::PutSelf.new

      parts.each do |part|
        part.compile(iseq)
      end

      iseq << Insn::ConcatStrings.new(parts.length) if parts.length > 1
      iseq << Insn::OptSendWithoutBlock.new(CallData.new("`", 1, "FCALL|ARGS_SIMPLE"))
    end
  end

  class ZSuper
    def compile(iseq)
      iseq << Insn::PutSelf.new
      iseq << Insn::InvokeSuper.new(CallData.new(nil, 0, "FCALL|ARGS_SIMPLE|SUPER|ZSUPER"))
    end
  end
end
