module Voteable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :voteable
  end

  def total_vote_count_string
    t = self.total_vote_count
    "#{t}" + " vote".pluralize(t)
  end

  def total_vote_count
    self.up_vote_count + self.down_vote_count
  end

  def total_vote_score
    self.up_vote_count - self.down_vote_count
  end

  def up_vote_count
    self.votes.where(vote: true).size
  end

  def down_vote_count
    self.votes.where(vote: false).size
  end

end
