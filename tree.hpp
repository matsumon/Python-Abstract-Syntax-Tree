#include <iostream>
#include <vector>

class Tree{
    public:
        Tree(
                std::string node_type, 
                std::string value 
                // Tree * left_node, 
                // Tree * right_node
            ){
           this->node_type = node_type;
           this->value =value;
        //    this->left_node =left_node;
        //    this->right_node = right_node;
        }

        std::string node_type;
        std::string value;
        // Tree * left_node;
        // Tree * right_node;
        std::vector<Tree *> block;
        std::vector<Tree *> child;
};

