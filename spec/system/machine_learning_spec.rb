require "rails_helper"

describe "Machine learning" do
  let(:proposal) { create(:proposal) }
  let(:related_proposal) { create(:proposal) }
  let(:budget) { create(:budget) }
  let(:investment) { create(:budget_investment, budget: budget) }
  let(:related_investment) { create(:budget_investment) }
  let(:user_tag) { create(:tag, name: "user tag") }
  let(:ml_proposal_tag) { create(:tag, name: "machine learning proposal tag") }
  let(:ml_investment_tag) { create(:tag, name: "machine learning investment tag") }

  before do
    Setting["feature.machine_learning"] = true
    Setting["machine_learning.comments_summary"] = false
    Setting["machine_learning.related_content"] = false
    Setting["machine_learning.tags"] = false
  end

  describe "Comments summary" do
    scenario "is displayed for proposals if setting is enabled" do
      ml_summary_comment_proposal = create(:ml_summary_comment, commentable: proposal)

      visit proposal_path(proposal)

      within "#comments" do
        expect(page).not_to have_content "Comments summary"
        expect(page).not_to have_content "Content generated by AI / Machine Learning"
        expect(page).not_to have_content "#{ml_summary_comment_proposal.body}"
      end

      Setting["machine_learning.comments_summary"] = true

      visit proposal_path(proposal)

      within "#comments" do
        expect(page).to have_content "Comments summary"
        expect(page).to have_content "Content generated by AI / Machine Learning"
        expect(page).to have_content "#{ml_summary_comment_proposal.body}"
      end
    end

    scenario "is displayed for budget investments if setting is enabled" do
      ml_summary_comment_investment = create(:ml_summary_comment, commentable: investment)

      visit budget_investment_path(budget, investment)

      within "#tab-comments" do
        expect(page).not_to have_content "Comments summary"
        expect(page).not_to have_content "Content generated by AI / Machine Learning"
        expect(page).not_to have_content "#{ml_summary_comment_investment.body}"
      end

      Setting["machine_learning.comments_summary"] = true

      visit budget_investment_path(budget, investment)

      within "#tab-comments" do
        expect(page).to have_content "Comments summary"
        expect(page).to have_content "Content generated by AI / Machine Learning"
        expect(page).to have_content "#{ml_summary_comment_investment.body}"
      end
    end
  end

  describe "Related content" do
    scenario "is displayed for proposals if setting is enabled" do
      create(:related_content, parent_relationable: proposal,
                               child_relationable: related_proposal,
                               machine_learning: true)

      visit proposal_path(proposal)

      within ".related-content" do
        expect(page).to have_content "Related content (0)"
        expect(page).not_to have_selector ".related-content-title"
      end

      Setting["machine_learning.related_content"] = true

      visit proposal_path(proposal)

      within ".related-content" do
        expect(page).to have_content "Related content (1)"
        expect(page).to have_selector(".related-content-title")
        expect(page).to have_content "#{related_proposal.title}"
      end
    end

    scenario "is displayed for budget investments if setting is enabled" do
      create(:related_content, parent_relationable: investment,
                               child_relationable: related_investment,
                               machine_learning: true)
      visit budget_investment_path(budget, investment)

      within ".related-content" do
        expect(page).to have_content "Related content (0)"
        expect(page).not_to have_selector ".related-content-title"
      end

      Setting["machine_learning.related_content"] = true

      visit budget_investment_path(budget, investment)

      within ".related-content" do
        expect(page).to have_content "Related content (1)"
        expect(page).to have_selector(".related-content-title", count: 1)
        expect(page).to have_content "#{related_investment.title}"
      end
    end
  end

  describe "Tags" do
    before do
      proposal.update! tag_list: [user_tag]
      proposal.update! ml_proposal_tag_list: [ml_proposal_tag]
      investment.update! tag_list: [user_tag]
      investment.update! ml_investment_tag_list: [ml_investment_tag]
    end

    scenario "are displayed for proposals if setting is enabled" do
      visit proposal_path(proposal)

      within "#tags_proposal_#{proposal.id}" do
        expect(page).to have_link "user tag"
        expect(page).not_to have_link "machine learning proposal tag"
        expect(page).not_to have_link "machine learning investment tag"
      end

      expect(page).not_to have_content "Content generated by AI / Machine Learning"

      Setting["machine_learning.tags"] = true

      visit proposal_path(proposal)

      within "#tags_proposal_#{proposal.id}" do
        expect(page).not_to have_link "user tag"
        expect(page).to have_link "machine learning proposal tag"
        expect(page).not_to have_link "machine learning investment tag"
      end

      expect(page).to have_content "Content generated by AI / Machine Learning"
    end

    scenario "are displayed for budget investments if setting is enabled" do
      visit budget_investment_path(budget, investment)

      within "#tags_budget_investment_#{investment.id}" do
        expect(page).to have_link "user tag"
        expect(page).not_to have_link "machine learning proposal tag"
        expect(page).not_to have_link "machine learning investment tag"
      end

      expect(page).not_to have_content "Content generated by AI / Machine Learning"

      Setting["machine_learning.tags"] = true

      visit budget_investment_path(budget, investment)

      within "#tags_budget_investment_#{investment.id}" do
        expect(page).not_to have_link "user tag"
        expect(page).not_to have_link "machine learning proposal tag"
        expect(page).to have_link "machine learning investment tag"
      end

      expect(page).to have_content "Content generated by AI / Machine Learning"
    end
  end
end