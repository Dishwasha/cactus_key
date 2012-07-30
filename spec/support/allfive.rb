class AllFive
  include CactusKev::PerfectHash

  def five_card_frequency
    deck = init_deck
    hand = []
    freq = [0,0,0,0,0,0,0,0,0]

    puts "Cactus Kev's Hand Evaluator with Perfect Hash by Paul Senzee\n"
    puts "------------------------------------------------------------\n\n"
    puts "Enumerating and evaluating all 2,598,960 unique five-card poker hands...\n\n"

    Benchmark.bm(7) do |x|
      x.report(:result) {
        (0..47).each do |a|
          hand[0] = deck[a]
          ((a+1)..48).each do |b|
            hand[1] = deck[b]
            ((b+1)..49).each do |c|
              hand[2] = deck[c]
              ((c+1)..50).each do |d|
                hand[3] = deck[d]
                ((d+1)..51).each do |e|
                  hand[4] = deck[e]

                  i = eval_5hand_fast( hand[0], hand[1], hand[2], hand[3], hand[4] )
                  j = hand_rank(i)
                  freq[j]+=1
                end
              end
            end
          end
        end
      }
    end
    freq
  end
end