module Bear
  Bear = Struct.new(:id, :name, :type, :hibernating) do

    def is_grizzly?
      self.type == 'Grizzly'
    end
  end
end