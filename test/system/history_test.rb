require "application_system_test_case"

class HistoryTest < ApplicationSystemTestCase
  PAGE_SIZE = 20

  test "atom link on user's history is not modified" do
    user = create(:user)
    create(:changeset, :user => user, :num_changes => 1) do |changeset|
      create(:changeset_tag, :changeset => changeset, :k => "comment", :v => "first-changeset-in-history")
    end

    visit "#{user_path(user)}/history"
    changesets = find "div.changesets"
    changesets.assert_text "first-changeset-in-history"

    assert_css "link[type='application/atom+xml'][href$='#{user_path(user)}/history/feed']", :visible => false
  end

  test "have only one list element on user's changesets page" do
    user = create(:user)
    create_visible_changeset(user, "first-changeset-in-history")
    create_visible_changeset(user, "bottom-changeset-in-batch-2")
    (PAGE_SIZE - 1).times do
      create_visible_changeset(user, "next-changeset")
    end
    create_visible_changeset(user, "bottom-changeset-in-batch-1")
    (PAGE_SIZE - 1).times do
      create_visible_changeset(user, "next-changeset")
    end

    assert_nothing_raised do
      visit "#{user_path(user)}/history"
      changesets = find "div.changesets"
      changesets.assert_text "bottom-changeset-in-batch-1"
      changesets.assert_no_text "bottom-changeset-in-batch-2"
      changesets.assert_no_text "first-changeset-in-history"
      changesets.assert_selector "ol", :count => 1
      changesets.assert_selector "li[data-changeset]", :count => PAGE_SIZE

      click_on "Older Changesets"
      changesets.assert_text "bottom-changeset-in-batch-1"
      changesets.assert_text "bottom-changeset-in-batch-2"
      changesets.assert_no_text "first-changeset-in-history"
      changesets.assert_selector "ol", :count => 1
      changesets.assert_selector "li[data-changeset]", :count => 2 * PAGE_SIZE

      click_on "Older Changesets"
      changesets.assert_text "bottom-changeset-in-batch-1"
      changesets.assert_text "bottom-changeset-in-batch-2"
      changesets.assert_text "first-changeset-in-history"
      changesets.assert_selector "ol", :count => 1
      changesets.assert_selector "li[data-changeset]", :count => (2 * PAGE_SIZE) + 1
    end
  end

  test "user history starts before specified changeset" do
    user = create(:user)
    changeset1 = create_visible_changeset(user, "1st-changeset-in-history")
    changeset2 = create_visible_changeset(user, "2nd-changeset-in-history")
    changeset3 = create(:changeset)

    visit "#{user_path user}/history?before=#{changeset1.id}"

    within_sidebar do
      assert_no_link "1st-changeset-in-history"
      assert_no_link "2nd-changeset-in-history"
    end

    visit "#{user_path user}/history?before=#{changeset2.id}"

    within_sidebar do
      assert_link "1st-changeset-in-history"
      assert_no_link "2nd-changeset-in-history"
    end

    visit "#{user_path user}/history?before=#{changeset3.id}"

    within_sidebar do
      assert_link "1st-changeset-in-history"
      assert_link "2nd-changeset-in-history"
    end
  end

  test "user history starts after specified changeset" do
    user = create(:user)
    changeset0 = create(:changeset)
    changeset1 = create_visible_changeset(user, "1st-changeset-in-history")
    changeset2 = create_visible_changeset(user, "2nd-changeset-in-history")

    visit "#{user_path user}/history?after=#{changeset2.id}"

    within_sidebar do
      assert_no_link "1st-changeset-in-history"
      assert_no_link "2nd-changeset-in-history"
    end

    visit "#{user_path user}/history?after=#{changeset1.id}"

    within_sidebar do
      assert_no_link "1st-changeset-in-history"
      assert_link "2nd-changeset-in-history"
    end

    visit "#{user_path user}/history?after=#{changeset0.id}"

    within_sidebar do
      assert_link "1st-changeset-in-history"
      assert_link "2nd-changeset-in-history"
    end
  end

  test "update sidebar when before param is included and map is moved" do
    changeset1 = create(:changeset, :num_changes => 1, :min_lat => 50000000, :max_lat => 50000001, :min_lon => 50000000, :max_lon => 50000001)
    create(:changeset_tag, :changeset => changeset1, :k => "comment", :v => "changeset-at-fives")
    changeset2 = create(:changeset, :num_changes => 1, :min_lat => 50100000, :max_lat => 50100001, :min_lon => 50100000, :max_lon => 50100001)
    create(:changeset_tag, :changeset => changeset2, :k => "comment", :v => "changeset-close-to-fives")
    changeset3 = create(:changeset)

    visit "/history?before=#{changeset3.id}#map=17/5/5"

    within_sidebar do
      assert_link "changeset-at-fives"
      assert_no_link "changeset-close-to-fives"
    end

    find("#map [aria-label='Zoom Out']").click(:shift)

    within_sidebar do
      assert_link "changeset-at-fives"
      assert_link "changeset-close-to-fives"
    end

    assert_current_path history_path
  end

  test "all changesets are listed when fully zoomed out" do
    user = create(:user)
    [-177, -90, 0, 90, 177].each do |lon|
      create(:changeset, :user => user, :num_changes => 1,
                         :min_lat => 0 * GeoRecord::SCALE, :min_lon => (lon - 1) * GeoRecord::SCALE,
                         :max_lat => 1 * GeoRecord::SCALE, :max_lon => (lon + 1) * GeoRecord::SCALE) do |changeset|
        create(:changeset_tag, :changeset => changeset, :k => "comment", :v => "changeset-at-lon(#{lon})")
      end
    end

    visit history_path(:anchor => "map=0/0/0")

    within_sidebar do
      assert_link "changeset-at-lon(-177)", :count => 1
      assert_link "changeset-at-lon(-90)", :count => 1
      assert_link "changeset-at-lon(0)", :count => 1
      assert_link "changeset-at-lon(90)", :count => 1
      assert_link "changeset-at-lon(177)", :count => 1
    end
  end

  private

  def create_visible_changeset(user, comment)
    create(:changeset, :user => user, :num_changes => 1) do |changeset|
      create(:changeset_tag, :changeset => changeset, :k => "comment", :v => comment)
    end
  end
end
