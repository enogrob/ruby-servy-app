module BearController
  require_relative 'bear'
  require_relative 'wildthings'

  def self.index(conv)
    _ = Wildthings::list_bears
    _ = _.select{|bear| bear.is_grizzly?}
    _ = _.sort_by!{|bear| bear.name}
    _ = _.map{|bear| bear_item(bear)}
    _ = _.join

    conv[:status] = 200
    conv[:resp_body] = "<ul>#{_}</ul>"
    conv
  end

  def self.show(conv, id)
    bear = Wildthings::get_bear(id)
    conv[:resp_body] = "<h1>Bear #{bear.id}: #{bear.name}</h1>"

    conv[:status] = 200
  end

  def self.create(conv)
    conv[:resp_body] = "Created a #{conv.params[:type]} bear named #{conv.params[:name]}"
    conv[:status] = 201
  end

  def self.delete(conv, id)
    conv[:resp_body] = "Deleting a bear is forbidden!"
    conv[:status] = 403
  end

  private

  def self.bear_item(bear)
    "<li>#{bear.name} - #{bear.type}<</li>"
  end
end


