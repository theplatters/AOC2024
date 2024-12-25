(require '[clojure.string :as str]
         '[clojure.math :as math])

(defn extract-numbers [line]
  (->> line
       (re-seq #"\d+")
       (map #(Integer. %))))

(def file   (-> "input17.txt"
                slurp
                (str/split #"\n\n")))

(def registers (let [[A,B,C] (extract-numbers (first file))]
                 {:A A
                  :B B
                  :C C}))

(def program (vec (extract-numbers (last file))))

(defn combcode [combo register]
  (case combo
    0 0
    1 1
    2 2
    3 3
    4 (:A register)
    5 (:B register)
    6 (:C register)))

(defn big_div [a b]
  (bit-shift-right a b))

(def opcodes
  {0 (fn [combo registers program-pointer out]
       [(assoc registers :A (big_div (:A registers) (combcode combo registers)))
        (+ 2 program-pointer) out])
   1 (fn [combo registers program-pointer out]
       [(assoc registers :B (bit-xor (:B registers) combo)) (+ 2 program-pointer) out])
   2 (fn [combo registers program-pointer out]
       [(assoc registers :B (mod (combcode combo registers) 8)) (+ 2 program-pointer) out])
   3 (fn [combo registers program-pointer out]
       (if (= (:A registers) 0)
         [registers (+ 2 program-pointer) out]
         [registers combo out]))
   4 (fn [_ registers program-pointer out] [(assoc registers :B (bit-xor (:B registers) (:C registers))) (+ 2 program-pointer) out])
   5 (fn [combo registers program-pointer out] [registers (+ 2 program-pointer) (conj out (mod (combcode combo registers) 8))])
   6 (fn [combo registers program-pointer out]
       [(assoc registers :B (big_div (:A registers) (combcode combo registers)))
        (+ 2 program-pointer) out])
   7 (fn [combo registers program-pointer out]
       [(assoc registers :C (big_div (:A registers) (combcode combo registers)))
        (+ 2 program-pointer) out])})

(defn evaluate
  ([program registers program-pointer out] (let [operation (get opcodes (nth program program-pointer))
                                                 combo (nth program (inc program-pointer))
                                                 [register-new program-pointer-new out-new] (operation combo registers program-pointer out)]
                                             (if (and (< program-pointer-new (count program)) (not (neg? program-pointer-new)))
                                               (evaluate program register-new program-pointer-new out-new)
                                               [register-new out-new])))
  ([program registers] (evaluate program registers 0 (vector))))

(evaluate program registers)
;; PART 2

(defn is-next? [n m program]
  (let [[_ out] (evaluate program {:A  m :B 0 :C 0})]
    (= (first out) (nth program n))))

(defn next-correct-register-value [n program prev]
  (letfn [(correct-vaue [m]
            (if (is-next? n (+ (bit-shift-left prev 3) m)
                          program) (+ (bit-shift-left prev 3) m) (correct-vaue (inc m))))]
    (correct-vaue 0)))

(defn get-register-value [n program prev]
  (if (zero? n)
    (next-correct-register-value n  program prev)
    (get-register-value (dec n) program (next-correct-register-value n program prev))))

(get-register-value 15 program 0)
