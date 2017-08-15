module CapGCE
  class StatusTable
    include CapGCE::Utils

    def initialize(instances)
      @instances = instances
      output
    end

    def header_row
      [
        bold('Num'),
        bold('Name'),
        bold('ID'),
        bold('Type'),
        bold('IP'),
        bold('Zone'),
        bold('Roles'),
        bold('Stages')
      ]
    end

    def output
      table = Terminal::Table.new(
        style: {
          border_x: '',
          border_i: '',
          border_y: ''
        }
      )
      table.add_row header_row
      @instances.each_with_index do |instance, index|
        table.add_row instance_to_row(instance, index)
      end
      puts table.to_s
    end

    def instance_to_row(instance, index)
      [
        '%02d' % index,
        green(instance.name || ''),
        red(instance.id.to_s),
        cyan(instance.machine_type.split('/').last),
        bold(blue(CapGCE::Utils.contact_point(instance).join(','))),
        magenta(instance.zone.split('/').last),
        yellow(tag_value(instance, roles_tag)),
        yellow(tag_value(instance, stages_tag))
      ]
    end

    private

    (String.colors + String.modes).each do |format|
      define_method(format) do |string|
        if $stdout.tty?
          string.__send__(format)
        else
          string
        end
      end
    end
  end
end
