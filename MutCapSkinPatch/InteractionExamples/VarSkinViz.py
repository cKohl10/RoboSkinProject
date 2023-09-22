import cv2
import numpy as np

class VarSkinViz:
    def __init__(self, num_RX, num_TX):
        self.num_RX = num_RX
        self.num_TX = num_TX
        self.pixels_per_sensor = 70
        self.image = self.__create_image()
        self.heatData = [[0 for j in range(num_RX)] for i in range(num_TX)]


    def __create_image(self):
        blank_image = np.zeros((self.num_RX * self.pixels_per_sensor,
                                self.num_TX * self.pixels_per_sensor, 3),  np.uint8)
        return blank_image
    
    def show_image(self):
        cv2.imshow("blank image", self.image)
        cv2.waitKey(0)

    def update_vals(self, vals, calibVals):

        for r in range(self.num_TX):
            for t in range(self.num_RX):
                self.heatData[r][self.num_RX-(t+1)] = vals[r][t] - calibVals[r][t]
                print(self.heatData[r][self.num_RX-(t+1)])
                cur_r = r * self.pixels_per_sensor
                cur_t = t * self.pixels_per_sensor
                # set the blue channel of each square depended on 
                # the sensor value map
                in_val = self.heatData[r][self.num_RX-(t+1)]
                blue_val = self.translate(in_val, -20, 200, 0, 255)
                self.image[cur_r:cur_r + self.pixels_per_sensor,
                           cur_t:cur_t + self.pixels_per_sensor, 0] = 255
                self.image[cur_r:cur_r + self.pixels_per_sensor,
                           cur_t:cur_t + self.pixels_per_sensor, 1] = 255
                self.image[cur_r:cur_r + self.pixels_per_sensor,
                           cur_t:cur_t + self.pixels_per_sensor, 2] = 255
        # for idx, val in enumerate(val_list[0]):
        #     print("idx:", idx , val)
        #     break
            # self.image[]

    def translate(self, value, leftMin, leftMax, rightMin, rightMax):
        # Figure out how 'wide' each range is
        leftSpan = leftMax - leftMin
        rightSpan = rightMax - rightMin

        # Convert the left range into a 0-1 range (float)
        valueScaled = float(value - leftMin) / float(leftSpan)

        # Convert the 0-1 range into a value in the right range.
        return rightMin + (valueScaled * rightSpan)
        

if __name__ == "__main__":
    var_skin_viz = VarSkinViz(3, 10)
    var_skin_viz.show_image()