Then /^show me the releases$/ do
  RbRelease.find(:all).each{|release|
    puts "Release: #{release}"
  }
end

Then /^show me release (.+)$/ do |release_name|
  release = RbRelease.find_by_name(release_name)
  release.should_not be_nil
  puts "Release: #{release}"
  release.issues.each{|issue| puts "  Issue: #{issue}" }
end

Then /^show me the release backlog of (.+)$/ do |release_name|
  release = RbRelease.find_by_name(release_name)
  release.should_not be_nil
  RbStory.release_backlog(release).each{|issue|
    puts "  #{issue}"
  }
end

When /^I move story (.+) to the product backlog$/ do |story_name|
  story = RbStory.find_by_subject(story_name)
  story.init_journal(User.current)
  story.release = nil
  story.save
end

When /^I move story (.+) to the release (.+)$/ do |story_name,release_name|
  story = RbStory.find_by_subject(story_name)
  story.should_not be_nil
  release = RbRelease.find_by_name(release_name)
  release.should_not be_nil
  story.release = release
  story.save
end

Given /^I have set planned velocity to (\d+) points per (month|fortnight|week) for (.+)$/ do |velocity,velocity_timespan, release_name|
  release = RbRelease.find_by_name(release_name)
  release.planned_velocity = velocity
  release.save
end


When /^I add story (.+) to release (.+)$/ do |story_name, release_name|
  story = RbStory.find_by_subject(story_name)
  @story_params = {
    :id => story.id,
    :release_id => RbRelease.find_by_name(release_name).id
  }
  page.driver.post(
                      url_for(:controller => :rb_stories,
                              :action => :update,
                              :id => @story_params[:id],
                              :only_path => true),
                      @story_params
                  )
  verify_request_status(200)
  story.reload
end

Then /^story (.+) should belong to release (.+)$/ do |story_name, release_name|
  release = RbRelease.find_by_name(release_name)
  release.should_not be_nil
  story = RbStory.find_by_subject(story_name)
  story.should_not be_nil
  release.issues.exists?(story).should be_true
end

Then /^story (.+) should not belong to any release$/ do |story_name|
  story = RbStory.find_by_subject(story_name)
  story.should_not be_nil
  story.release_id.should be_nil
end

Then /^I should see the release backlog of (.+)$/ do |release|
  release = RbRelease.find_by_name(release)
  release.should_not be_nil
  page.should have_css("#stories-for-release-#{release.id}")
end

Then /^I should see (\d+) stories in the release backlog of (.+)$/ do |count, release|
  release = RbRelease.find_by_name(release)
  release.should_not be_nil
  page.all(:css, "#stories-for-release-#{release.id} .story").length.should == count.to_i
end

Then /^release "([^"]*)" should have (\d+) story points$/ do |release, points|
  release = RbRelease.find_by_name(release)
  release.should_not be_nil
  release.remaining_story_points.should == points.to_f
end

Then /^The release "([^"]*)" should be closed$/ do |release|
  release = RbRelease.find_by_name(release)
  release.status.should == 'closed'
  release.closed?.should be_true
end

Given /^I have made the following story mutations:$/ do |table|
  #Mutations happen at 'day' relative to the story's sprint
  table.hashes.each do |mutation|
    mutation.delete_if{|k, v| v.to_s.strip == '' }
    story = RbStory.find_by_subject(mutation.delete('story'))
    story.should_not be_nil
    current_sprint(story.fixed_version.name)
    set_now(mutation.delete('day'), :msg => story.subject, :sprint => current_sprint)
    Time.zone.now.should be >= story.created_on

    story.init_journal(User.current)

    status_name = mutation.delete('status').to_s
    if status_name.blank?
      status = nil
    else
      status = IssueStatus.find(:first, :conditions => ['name = ?', status_name])
      raise "No such status '#{status_name}'" unless status
      status = status.id
    end

    story.status_id = status if status
    story.save!.should be_true

    mutation.should == {}
  end
end

Given /^I accept story ([^"]*)$/ do |story_name|
  story = RbStory.find_by_subject(story_name)
  story.should_not be_nil
  status = IssueStatus.find(:first, :conditions => ['name = ?', "Accepted"])
  story.status_id = status.id
  story.save!.should be_true
end


Given /^I duplicate ([^"]*) to release ([^"]*) as ([^"]*)$/ do |story_old, release_name, story_new|
  issue = Issue.find_by_subject(story_old)
  release = RbRelease.find_by_name(release_name)
  issue.should_not be_nil
  release.should_not be_nil
  issue_copy = issue.copy({:release_id => release.id,
                           :fixed_version_id => nil,
                           :subject => story_new})
  issue_copy.save
end

Given /^I set story ([^"]*) release relationship to (auto|initial|continued|added)$/ do |story_name,relation_type|
  issue = Issue.find_by_subject(story_name)
  issue.should_not be_nil
  issue.release_relationship = relation_type
  issue.save
end

Then /^release "([^"]*)" should have (\d+) sprints$/ do |release, num|
  release = RbRelease.find_by_name(release)
  release.should_not be_nil
  release.sprints.size.should == num.to_i
end

Then /^show me the burndown data for release "([^"]*)"$/ do |release|
  release = RbRelease.find_by_name(release)
  burndown = release.burndown
  puts "days      #{release.days}"
  puts "closed    #{burndown[:closed_points]}"
  puts "added     #{burndown[:added_points]}"
  puts "bl points #{burndown[:backlog_points]}"
  puts "total     #{burndown[:total_points]}"
  puts "trend add #{burndown[:trend_added]}"
  puts "trend cls #{burndown[:trend_closed]}"
  puts "planned   #{burndown[:planned]}"

end

Then /^the release burndown for release "([^"]*)" should be:$/ do |release, table|
  release = RbRelease.find_by_name(release)
  burndown = release.burndown
  table.hashes.each do |metrics|
    sprint = metrics.delete('sprint')
    sprint = (sprint == 'start' ? 0 : sprint.to_i)
    metrics.keys.sort{|a, b| a.to_s <=> b.to_s}.each do |k|
      expect = metrics[k]
      got = burndown[k.intern][sprint]
      got = "%d, %s: %.1f" % [sprint, k, got]
      expect = "%d, %s: %.1f" % [sprint, k, expect]
      #puts "test: #{expect} == #{got}"
      got.should == expect
    end
  end
end

Then /^([^"]*) has planned timespan of (\d+) days starting from ([^"]*)$/ do |release_name, days, start|
  release = RbRelease.find_by_name(release_name)
  burndown = release.burndown

  start_date = Date.parse start
  expected_date = start_date + days.to_i

  burndown[:planned][0][0].should == start_date
  burndown[:planned][1][0].should == expected_date
end

Then /^([^"]*) has trend estimate end date at ([^"]*)$/ do |release_name, expected_end_date|
  release = RbRelease.find_by_name(release_name)
  burndown = release.burndown
  expected_end_date = Date.parse expected_end_date

  burndown.trend_estimate_end_date.should == expected_end_date
end


Then /^journal for "([^"]*)" should show change to release "([^"]*)"$/ do |story_name,release_name|
  release = RbRelease.find_by_name(release_name)
  story = RbStory.find_by_subject(story_name)
  found_change = false
  # Find journal entry containing change to release
  story.journals.each{|journal|
    journal.details.each{|jd|
      next unless jd.property == 'attr' && ['release_id'].include?(jd.prop_key)
      found_change = true if jd.value.to_i == release.id
    }
  }
  found_change.should be_true

  # Verify Backlogs issue history
  h = story.history.filter_release([RbIssueHistory.burndown_timezone.now.to_date])
  h[0][:release].should == release.id
end

