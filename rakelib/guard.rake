ERB_TEMPLATE = <<~HEREDOC
guard :shell do
  <% all_tasks.each do |t, files| %>
    watch(%r{^(<%= files.join('|') %>)$}) do |m|
      system("rake <%= t %>")
    end
  <% end %>
end
HEREDOC

desc "Generates a Guardfile from Rake tasks"
task :guard do
  app = Rake::application
  app.init
  app.load_rakefile

  all_tasks = {}
  app.tasks.each do |t|
    t.sources.each do |src|
      if File.file?(src) then
        all_tasks[t.name] = [] unless all_tasks[t.name]
        all_tasks[t.name] << src
      end
    end
  end
  template = ERB.new(ERB_TEMPLATE)
  File.write('Guardfile', template.result(binding))
end
