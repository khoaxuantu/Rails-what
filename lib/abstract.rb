module Abstract
  def abstract_methods(*args)
    puts "do abstract methods"
    args.each do |name|
      class_eval(<<-END, __FILE__, __LINE__)
        def #{name}(*args)
          raise NotImplementedError.new("You must implement #{name}.")
        end
      END
    end
  end
end
