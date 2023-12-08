(require '[clojure.string :as str])
(defn f [s]
    (apply *
        (map
            (fn [v] (let [[t d] v]
                ; Math in lisp syntax is so unreadable
                (+ (- t (* 2 (+ 1 (int (/ (- t (Math/sqrt (- (* t t) (* 4 d)))) 2))))) 1)))
            (apply map vector
                (map
                    (fn [line] (map #(Integer/parseInt %) (rest (str/split line #"\s+"))))
                    (str/split-lines s))))))
