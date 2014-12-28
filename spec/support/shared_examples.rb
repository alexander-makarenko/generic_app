shared_examples "is invalid and has errors" do |count, conditions={}|
  count_message = count == 1 ? 'an error' : "#{count} errors"
  specify %Q|is invalid and has #{count_message}|, conditions do
    expect(subject).to be_invalid
    expect(subject.errors.count).to eq(count)
  end
end

shared_examples "page has validation errors" do |conditions={}|
  specify "page has validation errors", conditions do
    expect(page).to have_selector("div.validation-errors")
  end
end

shared_examples "page has" do |options, conditions={}|
  if options[:h1]
    specify %Q|page has css "h1" with "#{options[:h1]}"|, conditions do
      expect(page).to have_selector('h1', text: options[:h1])
    end
  end
end

shared_examples "shows flash" do |type, contents, conditions={}|
  specify %Q|shows #{type} flash with "#{contents}"|, conditions do
    expect(page).to have_selector("div.flash-#{type}", text: contents)
  end
end