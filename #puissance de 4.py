#puissance de 4 
# la taille 
BOARD_Colonnes= 7
BOARD_Lignes = 6

# l'objeet du board du jeu 
class Board():
    def __init__(self):
        #la methode initialise les attribus de l'objet
        #le (self) aide a accéder a toutes les instances définies
        self.board = [[' ' for _ in range(BOARD_Colonnes)] for _ in range(BOARD_Lignes)]
        self.tour = 0 
        #aucun tour jouer 
        self.last_move = [-1, -1] # [r ,c] r=ligne, c=colonne 

    def print_board(self):
        print("\n")
        # /n est utilisé pour créé une nouvelle ligne 
        # numérotation des colonnes séparé 
        for r in range(BOARD_Colonnes):
            print(f"  ({r+1}) ", end="") 
            # les f-strings :insérer les expressions dans des chaines de caractères
        print("\n")

        # Print les "┃" du jeu 
        for r in range(BOARD_Lignes):
            print('|', end="")
            for c in range(BOARD_Colonnes):
                print(f"  {self.board[r][c]}  |", end="")
            print("\n")

        print(f"{'_' * 43}\n")
        # lignes du bas 


    def quelle_tour(self):
        players = ['X', '*']
        return players[self.tour % 2]
    # enchainenment des tours


    def limites(self, r, c):
        return (r >= 0 and r < BOARD_Lignes and c >= 0 and c < BOARD_Colonnes )
        #ne pas depacer les ligne encadrer les coups

    def turn(self, colonne):
        # chercher en bas 
        for i in range(BOARD_Lignes-1, -1, -1):
            if  self.board[i][colonne] == ' ':
                self.board[i][colonne] = self.quelle_tour()
                self.last_move = [i, colonne]
                # ctd voir et esseyer de trouver des espaces vides pour jouer 

                self.tour += 1
                return True

        return False

    def verifier_winner(self):
        last_ligne = self.last_move[0]
        last_colonnes = self.last_move[1]
        last_letter = self.board[last_ligne][last_colonnes]
        #apartir du dernier coup on vérifie si il ya des connections 

        # [r, c] directions
        directions = [[[-1, 0], 0, True], 
                      [[1, 0], 0, True], 
                      [[0, -1], 0, True],
                      [[0, 1], 0, True],
                      [[-1, -1], 0, True],
                      [[1, 1], 0, True],
                      [[-1, 1], 0, True],
                      [[1, -1], 0, True]]
        
        # chercher les directions 
        for a in range(4):
            for d in directions:
                r = last_ligne + (d[0][0] * (a+1))
                c = last_colonnes+ (d[0][1] * (a+1))

                if d[2] and self.limites(r, c) and self.board[r][c] == last_letter:
                    d[1] += 1 
                    #si on trouve 4 pieces du meme joueurs dans la ligne on arrete
                else:
                    # si non on arrete de chercher dans cette direction 
                    d[2] = False

        #voir si il y a des pieces dans les directions paires ctd gauche avec droite de la derniere piece joué 
        for i in range(0, 7, 2):
            if (directions[i][1] + directions[i+1][1] >= 3):
                self.print_board()
                print(f"{last_letter} is the winner!")
                return last_letter   

        # si non 
        return False

def play():
    # Initialiser le tableau du jeu 
    game = Board()

    game_over = False
    while not game_over:
        game.print_board()

        # l'enchainement 
        bon_coup = False
        while not bon_coup:
            user_move = input(f"{game.quelle_tour()}' - choisis une colonne (1-{BOARD_Colonnes}): ")
            try:
                bon_coup = game.turn(int(user_move)-1)
            except:
                print(f"choisir un chiffre entre 1 et {BOARD_Colonnes}") 
                #erreur ne pas choisir un chiffre supp a 7 

        # fin du jeu si un joueur gagne 
        game_over = game.verifier_winner()
        
        # si le tableau ce remplie sans gagnant le jeu ce termine 
        if not any(' ' in x for x in game.board):
            print("le jeu est nul..")
            return


if __name__ == '__main__':
    play()