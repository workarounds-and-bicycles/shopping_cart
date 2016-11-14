require "spec_helper"

describe ShoppingCart::Base do
  let(:shopping_cart) { ShoppingCart::Base.new(token, item_id) }
  before do
    Redis.new(db: '1').flushall
  end

  describe '.set' do
    context 'correct params' do
      let(:token) { 'kek' }
      let(:item_id) { 666 }
      let(:result) { { '666' => 1 } }

      it 'should works' do
        expect(shopping_cart.set).to eq true
        expect(shopping_cart.get).to eq result
      end
    end

    context 'wrong params' do
      let(:token) { 'kek' }
      let(:item_id) { nil }
      let(:result) { {} }

      it 'should return nil' do
        expect(shopping_cart.set).to eq nil
        expect(shopping_cart.get).to eq result
      end
    end
  end

  describe '.get' do
    context 'correct params' do
      let(:token) { 'kek' }
      let(:item_id) { 666 }
      let(:result) { {} }

      it 'should works' do
        expect(shopping_cart.get).to eq result
      end
      context 'when redis has smth' do
        let(:result) { { '666' => 1 } }

        it 'should works' do
          shopping_cart.set
          expect(shopping_cart.get).to eq result
        end
      end
    end

    context 'wrong params' do
      let(:token) { nil }
      let(:item_id) { nil }
      let(:result) { nil }

      it 'should return nil' do
        expect(shopping_cart.get).to eq result
      end
    end
  end

  describe '.by_item_id' do
    context 'correct params' do
      let(:token) { 'kek' }
      let(:item_id) { 666 }
      let(:result) { { '666' => 1 } }

      it 'should works' do
        shopping_cart.set
        expect(shopping_cart.by_item_id).to eq result
      end

      context 'when count of items is more than one' do
        before do
          (1...10).each do |id|
            ShoppingCart::Base.new(token, id).set
          end
        end

        it 'should works' do
          shopping_cart.set
          expect(shopping_cart.by_item_id).to eq result
        end
      end
    end

    context 'wrong params' do
      let(:token) { 'kek' }
      let(:item_id) { nil }
      let(:result) { nil }

      it 'should return nil' do
        expect(shopping_cart.set).to eq result
      end
    end

    context 'when item is absent' do
      let(:token) { 'kek' }
      let(:item_id) { 1488 }
      let(:result) { nil }
      it 'should return nil' do
        expect(shopping_cart.by_item_id).to eq result
      end
    end
  end

  describe '.delete' do
    context 'correct params' do
      let(:token) { 'kek' }
      let(:item_id) { 666 }
      let(:result_after_deleting) { {} }
      let(:result_before_deleting) { { '666' => 1 } }

      it 'should return empty hash' do
        shopping_cart.set
        expect(shopping_cart.get).to eq result_before_deleting
        shopping_cart.delete
        expect(shopping_cart.get).to eq result_after_deleting
      end

      context 'when count of items is more than one' do
        let(:result) { nil }
        let(:result_before_deleting) { { '666' => 1 } }
        before do
          [1...10].each do |id|
            ShoppingCart::Base.new(token, id).set
          end
        end

        it 'should return nil' do
          shopping_cart.set
          expect(shopping_cart.by_item_id).to eq result_before_deleting
          shopping_cart.delete
          expect(shopping_cart.by_item_id).to eq result
        end
      end
    end

    context 'when item_id is nil' do
      let(:token) { 'kek' }
      let(:item_id) { nil }
      let(:result) { { '15' => 1 } }

      it 'should delete nothing' do
        ShoppingCart::Base.new(token, 15).set
        expect(shopping_cart.get).to eq result
        shopping_cart.delete
        expect(shopping_cart.get).to eq result
      end
    end

    context 'when item is absent' do
      let(:token) { 'kek' }
      let(:item_id) { 1488 }
      let(:result) { { '15' => 1 } }

      it 'should delete nothing' do
        ShoppingCart::Base.new(token, 15).set
        expect(shopping_cart.get).to eq result
        shopping_cart.delete
        expect(shopping_cart.get).to eq result
      end
    end
  end

  describe '.increase_by_key' do
    context 'correct params' do
      let(:token) { 'kek' }
      let(:item_id) { 15 }
      let(:result) { { '15' => 5 } }

      it 'should increase quantity from 1 to 5' do
        shopping_cart.set
        4.times { shopping_cart.increase_by_key }
        expect(shopping_cart.get).to eq result
      end
    end

    context 'item_id is absent' do
      let(:token) { 'kek' }
      let(:item_id) { nil }
      let(:result) { { '15' => 1 } }

      it 'should increase nothing' do
        ShoppingCart::Base.new(token, 15).set
        4.times { shopping_cart.increase_by_key }
        expect(shopping_cart.get).to eq result
      end
    end
  end

  describe '.decrease_by_key' do
    context 'correct params' do
      let(:token) { 'kek' }
      let(:item_id) { 15 }
      let(:result) { { '15' => 4 } }

      it 'should increase quantity from 1 to 5 and decrease from 5 to 4' do
        shopping_cart.set
        4.times { shopping_cart.increase_by_key }
        shopping_cart.decrease_by_key
        expect(shopping_cart.get).to eq result
      end
    end

    context 'item_id is absent' do
      let(:token) { 'kek' }
      let(:item_id) { nil }
      let(:result) { { '15' => 1 } }

      it 'should decrease nothing' do
        ShoppingCart::Base.new(token, 15).set
        4.times { shopping_cart.decrease_by_key }
        expect(shopping_cart.get).to eq result
      end
    end

    context 'when quantity equal to zero' do
      let(:token) { 'kek' }
      let(:item_id) { nil }
      let(:result) { {} }

      it 'should decrease nothing' do
        shopping_cart.set
        shopping_cart.decrease_by_key
        expect(shopping_cart.get).to eq result
      end
    end
  end

  describe '.count' do
    context 'correct params' do
      let(:token) { 'kek' }
      let(:item_id) { nil }
      let(:result) { 10 }

      before do
        (0...10).each do |id|
          ShoppingCart::Base.new(token, id).set
        end
      end

      it 'should return 10' do
        expect(shopping_cart.count).to eq result
      end
    end
  end

  describe '.item_is_exists?' do
    context 'when item is exists' do
      let(:token) { 'kek' }
      let(:item_id) { 12 }

      it 'should return true' do
        shopping_cart.set
        expect(shopping_cart.item_is_exists?).to eq true
      end
    end

    context 'when item is absent' do
      let(:token) { 'kek' }
      let(:item_id) { 12 }

      it 'should return false' do
        ShoppingCart::Base.new(token, 15).set
        expect(shopping_cart.item_is_exists?).to eq false
      end
    end

    context 'when item_id is absent' do
      let(:token) { 'kek' }
      let(:item_id) { nil }

      it 'should return true' do
        expect(shopping_cart.item_is_exists?).to eq nil
      end
    end
  end
end
