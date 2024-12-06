#lang racket

(require racket/list)
(define (read-file-line-by-line filename)
  (with-input-from-file filename
    (lambda ()
      (let loop ((line (read-line)) (result '()))
        (if (eof-object? line)
            (reverse result)
            (loop (read-line) (cons line result)))))))

(define (any-in? a b)
  (ormap (lambda (x) (memv x b)) a))

(define (take-while pred lst)
  (cond
    [(empty? lst) '()]                 ; Base case: If the list is empty, return an empty list
    [(pred (first lst))                ; If the predicate is true for the first element
     (cons (first lst) (take-while pred (rest lst)))] ; Include the element and recurse
    [else '()]))                       ; If the predicate fails, stop and return the result

(define (rules_to_map ls)
  (letrec ([rh (lambda (l h)
  (match l 
    [(cons x xs) (rh xs (if (hash-has-key? h (second x))
                                                        (hash-set h (second x) (cons (first x) (hash-ref h (second x))))
                                                        (hash-set h (second x) (list (first x)))))]
    [_ h]))]) (rh ls (hash))))

(define (middle-element lst)
  (list-ref lst (quotient (length lst) 2)))

(define (check-rules sequence rules)
  (letrec ([loop (lambda (seq rules)
    (match seq
      [(cons x xs)
       (if (hash-has-key? rules x)
           (let ([rule-values (hash-ref rules x)])
             (if (any-in? xs rule-values)
                 #f
                 (loop xs rules)))
           (loop xs))]
      [_ #t]))]) (loop sequence rules))) ; Base case: no more elements, return #t

(define lines (read-file-line-by-line "input5.txt"))

(define rules (map (compose rest (lambda (n) (map string->number n)))
            (map (lambda (n)
                   (regexp-match #px"(\\d+)\\|(\\d+)" n )) (take-while (lambda (n) (not (string=? "" n))) (read-file-line-by-line "input5.txt")))))

(define rules-map (rules_to_map rules))
(define sequences (map (lambda (n) (map string->number n)) 
     (map (lambda (n) (string-split n ","))  (take-while (lambda (n) (not (string=? "" n))) (reverse lines)))))

(foldl + 0 (map middle-element (filter (lambda (n) (check-rules n rules-map))  sequences)))

(define (sort-sequence a b rules)
  (not (memv b (hash-ref rules a '()))))

(foldl + 0 (map middle-element (map (lambda (seq) (sort seq (lambda (a b) (sort-sequence a b rules-map)))) (filter (lambda (n) (not (check-rules n rules-map)))  sequences))))

