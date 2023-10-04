# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Todo, type: :model do
  context 'test1' do
    it { expect(Todo.all).to eq [] }
    it { expect(Todo.first).to eq nil }

    let(:m) do
      t = Todo.new
      t.content = 'test'
      t.priority = 'high'
      t.save!
      t
    end

    it { expect(m.content).to eq 'test' }
    it { expect(m.priority).to eq 'high' }
  end
end
