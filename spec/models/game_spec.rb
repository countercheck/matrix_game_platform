require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(3).is_at_most(100) }
    it { should validate_presence_of(:description) }
    it { should validate_length_of(:description).is_at_most(1000) }
    it { should validate_presence_of(:max_participants) }
    it { should validate_numericality_of(:max_participants).is_greater_than(0) }
    it { should validate_presence_of(:min_participants) }
    it { should validate_numericality_of(:min_participants).is_greater_than(0) }
    
    it 'validates that max_participants is greater than or equal to min_participants' do
      game = build(:game, min_participants: 5, max_participants: 3)
      expect(game).not_to be_valid
      expect(game.errors[:max_participants]).to include('must be greater than or equal to min participants')
    end
    
    describe 'timestamps' do
      it { is_expected.to respond_to(:started_at) }
      it { is_expected.to respond_to(:completed_at) }
    end
  end

  describe 'associations' do
    # We'll add these later when we implement relationships
  end

  describe 'scopes' do
    let!(:upcoming_game) { create(:game, started_at: nil, completed_at: nil) }
    let!(:in_progress_game) { create(:game, :started, completed_at: nil) }
    let!(:completed_game) { create(:game, :completed) }

    describe '.upcoming' do
      it 'returns games that have not started' do
        expect(Game.upcoming).to include(upcoming_game)
        expect(Game.upcoming).not_to include(in_progress_game, completed_game)
      end
    end

    describe '.in_progress' do
      it 'returns games that have started but not completed' do
        expect(Game.in_progress).to include(in_progress_game)
        expect(Game.in_progress).not_to include(upcoming_game, completed_game)
      end
    end

    describe '.completed' do
      it 'returns games that have been completed' do
        expect(Game.completed).to include(completed_game)
        expect(Game.completed).not_to include(upcoming_game, in_progress_game)
      end
    end
  end

  describe 'instance methods' do
    let(:game) { build(:game) }

    describe '#status' do
      it 'returns :upcoming when not started' do
        expect(game.status).to eq(:upcoming)
      end

      it 'returns :in_progress when started but not completed' do
        game.started_at = Time.current
        expect(game.status).to eq(:in_progress)
      end

      it 'returns :completed when completed' do
        game.started_at = 1.day.ago
        game.completed_at = Time.current
        expect(game.status).to eq(:completed)
      end
    end

    describe '#start!' do
      it 'sets started_at to current time' do
        expect { game.start! }.to change { game.started_at }.from(nil)
        expect(game.started_at).to be_within(1.second).of(Time.current)
      end

      it 'returns false if already started' do
        game.start!
        expect(game.start!).to be false
      end
    end

    describe '#complete!' do
      before { game.start! }

      it 'sets completed_at to current time' do
        expect { game.complete! }.to change { game.completed_at }.from(nil)
        expect(game.completed_at).to be_within(1.second).of(Time.current)
      end

      it 'returns false if not started' do
        game = build(:game, started_at: nil)
        expect(game.complete!).to be false
      end

      it 'returns false if already completed' do
        game.complete!
        expect(game.complete!).to be false
      end
    end
  end
end
