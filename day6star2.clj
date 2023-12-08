(require '[clojure.string :as str])
(defn f [s]
    (let [[t d] (map
        #(Long/parseLong (str/replace (second (str/split % #":")) #"\s+" ""))
        (str/split-lines s))]
        (+ (- t (* 2 (+ 1 (int (/ (- t (Math/sqrt (- (* t t) (* 4 d)))) 2))))) 1)))
