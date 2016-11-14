require 'redis'
require 'json'

module ShoppingCart
  class Base
    DEFAULT_COUNT = 1
    ZERO = 0
    WEEK = 604_800 # seconds
    CLIENT = Redis.new(db: '1')

    attr_reader :token, :item_id

    def initialize(token, item_id = nil)
      @token = token
      @item_id = item_id
    end

    def set
      return if item_id.nil?
      CLIENT.set(token, add_item.to_json)
      expire_after_week
    end

    def get
      return if token.to_s.empty?
      response = CLIENT.get(token)
      response.nil? ? {} : parse(response)
    end

    def by_item_id
      return if item_id.nil? || !item_is_exists?
      response = get
      value = response[item_id.to_s]
      { item_id.to_s => value }
    end

    def delete
      return if item_id.nil? || !item_is_exists?
      CLIENT.set(token, delete_item.to_json)
      expire_after_week
    end

    def increase_by_key
      return if item_id.nil? || !item_is_exists?
      hash = get
      value = hash[item_id.to_s] + 1
      hash[item_id.to_s] = value
      CLIENT.set(token, hash.to_json)
      expire_after_week
    end

    def decrease_by_key
      return if item_id.nil? || !item_is_exists?
      hash = get
      value = hash[item_id.to_s]
      value -= 1

      if value == 0
        hash.delete(item_id.to_s)
      else
        hash[item_id.to_s] = value
      end

      CLIENT.set(token, hash.to_json)
      expire_after_week
    end

    def count
      get.empty? ? ZERO : get.size
    end

    def item_is_exists?
      return if item_id.nil?
      get.any? { |key, _value| key.to_i == item_id }
    end

    private

    def add_item
      hash = {}
      hash[item_id.to_s] = DEFAULT_COUNT
      get.empty? ? hash : merge_as_uniq
    end

    def merge_as_uniq
      hash = {}
      hash[item_id.to_s] = DEFAULT_COUNT
      get.merge(hash) unless get.any? { |key, _value| key.to_i == item_id }
    end

    def delete_item
      get.empty? ? {} : get.delete_if { |key, _value| key.to_s.to_i == item_id }
    end

    def expire_after_week
      CLIENT.expire(token, WEEK)
    end

    def parse(response)
      !response.nil? ? JSON.parse(response) : {}
    end
  end
end
