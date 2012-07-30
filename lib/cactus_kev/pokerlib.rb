require File.join(File.dirname(__FILE__), "perfect_hash", "arrays.rb")

module CactusKev
  module PerfectHash
    include Arrays

    STRAIGHT_FLUSH=0
    FOUR_OF_A_KIND=1
    FULL_HOUSE=2
    FLUSH=3
    STRAIGHT=4
    THREE_OF_A_KIND=5
    TWO_PAIR=6
    ONE_PAIR=7
    HIGH_CARD=8

    def rank(x)
      ((x >> 8) & 0xF)
    end

    # Have to use & 0xFFFFFFFF to drop bits above 32 bits
    def find_fast(u)
      u += 0xe91aaa35
      u ^= u >> 16
      u += (u << 8) & 0xFFFFFFFF
      u &= 0xFFFFFFFF
      u ^= u >> 4
      b  = (u >> 8) & 0x1ff
      a  = ((u + ((u << 2) & 0xFFFFFFFF)) & 0xFFFFFFFF) >> 19
      a ^ Arrays::HASH_ADJUST[b]
    end

    #   This routine initializes the deck.  A deck of cards is
    #   simply an integer array of length 52 (no jokers).  This
    #   array is populated with each card, using the following
    #   scheme:
    #
    #   An integer is made up of four bytes.  The high-order
    #   bytes are used to hold the rank bit pattern, whereas
    #   the low-order bytes hold the suit/rank/prime value
    #   of the card.
    #
    #   +--------+--------+--------+--------+
    #   |xxxbbbbb|bbbbbbbb|cdhsrrrr|xxpppppp|
    #   +--------+--------+--------+--------+
    #
    #   p = prime number of rank (deuce=2,trey=3,four=5,five=7,...,ace=41)
    #   r = rank of card (deuce=0,trey=1,four=2,five=3,...,ace=12)
    #   cdhs = suit of card
    #   b = bit turned on depending on rank of card
    def init_deck
      deck = []
      n = 0
      suit = 0x8000

      (0..3).each do
        (0..12).each do |j|
          deck[n] = Arrays::PRIMES[j] | (j << 8) | suit | (1 << (16+j))
          n+=1
        end
        suit >>= 1
      end
      deck
    end

    #  This routine will search a deck for a specific card
    #  (specified by rank/suit), and return the INDEX giving
    #  the position of the found card.  If it is not found,
    #  then it returns -1
    #
    def find_card(rank, suit, deck)
      (0..51).each do |i|
        c = deck[i]
        if (c & suit) && (rank(c) == rank)
          i
        else
          -1
        end
      end
    end

    def print_hand(hand, n)
      rank = "23456789TJQKA"

      (0..(n-1)).each do
        r = (hand >> 8) & 0xF
        suit = if hand & 0x8000
          'c'
        elsif hand & 0x4000
          'd'
        elsif hand & 0x2000
          'h'
        else
          's'
        end

        puts "#{rank[r]}#{suit}"
        hand+= 1
      end
    end

    def hand_rank(val)
      if val > 6185
        HIGH_CARD        # 1277 high card
      elsif val > 3325
        ONE_PAIR         # 2860 one pair
      elsif val > 2467
        TWO_PAIR         #  858 two pair
      elsif val > 1609
        THREE_OF_A_KIND  #  858 three-kind
      elsif val > 1599
        STRAIGHT         #   10 straights
      elsif val > 322
        FLUSH            # 1277 flushes
      elsif val > 166
        FULL_HOUSE       #  156 full house
      elsif val > 10
        FOUR_OF_A_KIND   #  156 four-kind
      else
        STRAIGHT_FLUSH   #  10 straight-flushes
      end
    end

    def eval_5hand_fast(c1, c2, c3, c4, c5)
      q = (c1 | c2 | c3 | c4 | c5) >> 16
      if (c1 & c2 & c3 & c4 & c5 & 0xf000) > 0
        Arrays::FLUSHES[q] # check for flushes and straight flushes
      elsif (s = Arrays::UNIQUE5[q]) && s > 0
        s          # check for straights and high card hands
      else
        Arrays::HASH_VALUES[find_fast((c1 & 0xff) * (c2 & 0xff) * (c3 & 0xff) * (c4 & 0xff) * (c5 & 0xff))]
      end
    end

    def eval_5hand(hand)
      c1 = hand[0]
      c2 = hand[1]
      c3 = hand[2]
      c4 = hand[3]
      c5 = hand[4]

      eval_5hand_fast(c1, c2, c3, c4, c5)
    end


    # This is a non-optimized method of determining the
    # best five-card hand possible out of seven cards.
    # I am working on a faster algorithm.

    def eval_7hand(hand)
      best = 9999
      subhand = []

      (0..20).each do |i|
        (0..4).each do |j|
          subhand[j] = hand[ Arrays::PERM7[i][j] ]
          q = eval_5hand(subhand)
          if q < best
            best = q
          else
            return best
          end
        end
      end
    end
  end
end