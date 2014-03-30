class WordSet < ActiveRecord::Base
  extend SearchConcern

  has_and_belongs_to_many :words

  attr :current_query

  module ClassMethods
    attr        :current_query
    attr_writer :current_query

    def search_for(string, type="include")
      joins(:words).includes(:words)
        .where("words.text ILIKE ?", ilike_string(string, type))
        .order("lower(words.text) ASC")
    end

    def all_with_words
      joins(:words).includes(:words)
        .order("lower(words.text) ASC")
    end

  end
  extend ClassMethods

  def words= words
    words.map! { |w| w.is_a?(Word) ? w : Word.find_or_create_by(text: w) }
    super words
  end

  def words_matches_preceding(string=nil)
    string.downcase! if string.is_a? String

    current_query = string

    return word_order_lists[string] if word_order_lists[string]

    all_words = words.order("lower(text) DESC").all
    
    return word_order_lists[string] = all_words.sort if string.nil?

    begins    = []
    includes  = []
    other     = []

    all_words.each do |w|
      case w.text.index(string)
      when nil
        other
      when 0
        begins
      else
        includes
      end << w
    end

    return word_order_lists[string] = begins.sort + includes.sort + other.sort
  end

  def words_ordered_by_query(query=nil)
    words_matches_preceding(query)
  end

  def words_ordered_by_current_query
    words_ordered_by_query(current_query)
  end

  def current_query
    @current_query || self.class.current_query
  end

  def <=> another
    words_ordered_by_current_query.first.text.downcase <=> another.words_ordered_by_current_query.first.text.downcase
  end


  protected


  def word_order_lists
    @word_order_lists ||= {}
  end


end